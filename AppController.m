//
//  Created by Rodolfo Puig on 9/24/12.
//  Copyright 2012 NBC Universal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppController.h"
#import "FileOperation.h";

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

- (void) dealloc {
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
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)start:(id)sender {
    if (!_isRunning) {
        NSLog(@"Process file queue");
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
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(threadProgress) userInfo:nil repeats:NO];
    } else {
        [entity setStatus:@"Done"];
        [_tableView reloadData];
        [self nextFile];
    }
}

- (void)processFiles {
    if (_filePos < _fileTotal) {
        FileOperation * entity = [_fileQueue objectAtIndex:_filePos];
        if (![entity error]) {
            NSLog(@"Processing file %d of %d", _filePos+1, _fileTotal);
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
            [args addObject:[NSString stringWithFormat:@"%@/cc1.srt", [entity outputDir]]];
            [args addObject:@"-o2"];                // Output custom Field 2 file
            [args addObject:[NSString stringWithFormat:@"%@/cc2.srt", [entity outputDir]]];
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
            NSLog(@"Skipping file %d of %d", _filePos+1, _fileTotal);
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

@end