//
//  Created by Rodolfo Puig on 9/24/12.
//  Copyright 2012 NBC Universal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <Python/Python.h>
#import "AppController.h"
#import "FileOperation.h"

@implementation AppController

@synthesize window      = _window;
@synthesize tableView   = _tableView;
@synthesize fileManager = _fileManager;
@synthesize fileQueue   = _fileQueue;
@synthesize fileTotal   = _fileTotal;
@synthesize filePos     = _filePos;
@synthesize ccextractor = _ccextractor;
@synthesize cctask      = _cctask;
@synthesize isRunning   = _isRunning;

- (id)init {
    if (self = [super init]) {
        self.fileManager = [[NSFileManager alloc] init];
        self.fileQueue   = [[NSMutableArray alloc] init];
        self.filePos     = 0;
        self.fileTotal   = 0;
        self.isRunning   = NO;
    }

    return self;
}

- (void)dealloc {
    [_tableView release];
    [_fileManager release];
    [_fileQueue release];
    [_ccextractor release];
    [_cctask release];
    [super dealloc];
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)files {
    for (NSString * file in files) {
        FileOperation * entity = [[FileOperation alloc] initWithFilePath:[NSString stringWithFormat:@"%@", file]];
        NSString * outputDir   = [entity outputDir];
        NSError * error        = nil;
        BOOL isDir;
        [entity setStatus:@"Waiting"];
        if (![_fileManager fileExistsAtPath:outputDir isDirectory:&isDir]) {
            if (![_fileManager createDirectoryAtPath:outputDir withIntermediateDirectories:YES attributes:nil error:&error]) {
                [entity setError:error];
            }
        }
        // Store entity
        [_fileQueue addObject:entity];
        // Increment file total
        _fileTotal++;
    }
    [_tableView reloadData];
    [self start:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)start:(id)sender {
    if (!_isRunning) {
        NSLog(@"Processing file queue");
        _isRunning = YES;
        [self processFiles];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger count = 0;
    if (_fileQueue) {
        count = [_fileQueue count];
    }

    return count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    id output                  = @"";
    FileOperation * entity     = [_fileQueue objectAtIndex:rowIndex];
    NSString * columnIdentifer = [aTableColumn identifier];
    if (entity) {
        if ([columnIdentifer isEqualToString:@"path"]) {
            output = [entity filepath];
        }
        if ([columnIdentifer isEqualToString:@"status"]) {
            if ([entity error]) {
                output = [[entity error] localizedDescription];
            } else {
                output = [entity status];
            }
        }
    }

    return output;
}

- (void)getData:(NSNotification *)notification {
    [NSThread detachNewThreadSelector:@selector(threadStart) toTarget:self withObject:nil];
}

- (void)threadStart {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self performSelectorOnMainThread:@selector(threadProgress) withObject:nil waitUntilDone:NO];
    [pool release];
}

- (void)threadProgress {
    FileOperation * entity = [_fileQueue objectAtIndex:_filePos];
    NSData * dataRead      = nil;
    if ((dataRead = [[entity output] availableData]) && [dataRead length]) {
        //NSString * textRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
        //NSLog(@"read %3ld: %@", (long)[textRead length], textRead);
        // TODO: process script output
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(threadProgress) userInfo:nil repeats:NO];
    } else {
        [self export:entity];
        [entity setStatus:@"Done"];
        [_tableView reloadData];
        [self nextFile];
    }
}

- (void)processFiles {
    if (_filePos < _fileTotal) {
        FileOperation * entity = [_fileQueue objectAtIndex:_filePos];
        if (![entity error]) {
            NSLog(@"Processing file %ld of %ld", _filePos+1, _fileTotal);
            [entity setStatus:@"Processing"];
            _ccextractor = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ccextractor"];
            _cctask      = [[NSTask alloc] init];
            // Create pipes
            NSPipe * stdout = [NSPipe pipe];
            NSPipe * stderr = [NSPipe pipe];
            [_cctask setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
            [_cctask setStandardOutput:stdout];
            [_cctask setStandardError:stderr];
            NSFileHandle * outputHandle = [[_cctask standardError] fileHandleForReading];
            [outputHandle readInBackgroundAndNotify];
            [entity setOutput:outputHandle];
            // Create arguments
            NSMutableArray * args = [[NSMutableArray new] autorelease];
            [args addObject:@"-out=srt"];           // Output SubRip files
            [args addObject:@"-o1"];                // Output custom Field 1 file
            [args addObject:[NSString stringWithFormat:@"%@/es.srt", [entity outputDir]]];
            [args addObject:@"-o2"];                // Output custom Field 2 file
            [args addObject:[NSString stringWithFormat:@"%@/en.srt", [entity outputDir]]];
            [args addObject:@"-utf8"];              // Encode subtitles in UTF-8
            [args addObject:@"-nofc"];              // Disable font color tags
            [args addObject:@"-noru"];              // Disable roll-up output
            [args addObject:@"-trim"];              // Trim lines
            [args addObject:@"-12"];                // Output Field 1 & Field 2 data
            [args addObject:@"--gui_mode_reports"];
            [args addObject:[NSString stringWithFormat:@"%@", [entity filepath]]];
            [_cctask setArguments: args];
            // Launch task 
            [_cctask setLaunchPath: _ccextractor];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData:) name:NSFileHandleReadCompletionNotification object:outputHandle];
            [_cctask launch];
            [_tableView reloadData];
        } else {
            NSLog(@"Skipping file %ld of %ld", _filePos+1, _fileTotal);
            [self nextFile];
        }
    } else {
        _isRunning = NO;
        NSBeep();
    }
}

- (void)nextFile {
    _filePos++;
    [self processFiles];
}

- (void)export:(FileOperation *)entity {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSString * path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"parser.py"];
    NSString * script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString * cc1Input = [NSString stringWithFormat:@"%@/es.srt", [entity outputDir]];
    NSString * cc1Output = [NSString stringWithFormat:@"%@/%@_es.xml", [entity outputDir], [entity filename]];
    NSString * cc2Input = [NSString stringWithFormat:@"%@/en.srt", [entity outputDir]];
    NSString * cc2Output = [NSString stringWithFormat:@"%@/%@_en.xml", [entity outputDir], [entity filename]];
    NSString * outputScript = [NSString stringWithFormat:@"%@\nparser = SubtitleParser()\nparser.parse('%@')\nparser.export('%@', 'es-us')\nunlink('%@')\nparser.parse('%@')\nparser.export('%@', 'en-us')\nunlink('%@')", script, cc1Input, cc1Output, cc1Input, cc2Input, cc2Output, cc2Input];
    Py_Initialize();
    PyRun_SimpleString([outputScript UTF8String]);
    [pool drain];
}

@end
