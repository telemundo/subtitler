//
//  Created by Rodolfo Puig on 9/24/12.
//  Copyright 2012 NBC Universal. All rights reserved.
//

#import "AppController.h"
#import "FileEntity.h";

@implementation AppController

@synthesize _window;
@synthesize _tableView;
@synthesize _fileQueue;
@synthesize _filePos;
@synthesize _fileTotal;
@synthesize _ccextractor;
@synthesize _task;

- (id)init {
    if (self = [super init]) {
        _fileQueue = [[NSMutableArray alloc] init];
        _filePos = 0;
        _fileTotal = 0;
    }
    return self;
}

- (void) dealloc {
    [_tableView release];
    [_fileQueue release];
    [_ccextractor release];
    [_task release];
    [super dealloc];
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)files {
    for (NSString *file in files) {
        FileEntity *entity = [[FileEntity alloc] init:[NSString stringWithFormat:@"%@", file]];
        BOOL isDir;
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *basedir = [NSString stringWithFormat:@"%@/%@", [entity basedir], [entity filename]];
        if (![fileManager fileExistsAtPath:basedir isDirectory:&isDir]) {
            if (![fileManager createDirectoryAtPath:basedir withIntermediateDirectories:YES attributes:nil error:NULL]) {
                [entity setStatus:1];
            }
        }
        [_fileQueue addObject:entity];
    }
    _fileTotal = [_fileQueue count];
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    //[_tableView setDataSource:self];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)start:(id)sender {
    while (_filePos < _fileTotal) {
        _ccextractor = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ccextractor"];
        _task = [[NSTask alloc] init];

        // Create pipes
        NSPipe *stdout = [NSPipe pipe];
        NSPipe *stderr = [NSPipe pipe];
        [_task setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
        [_task setStandardOutput:stdout];
        [_task setStandardError:stderr];
        NSFileHandle *readHandle = [[_task standardError] fileHandleForReading];
        
        // Generate subtitles from file
        FileEntity *entity = [_fileQueue objectAtIndex:_filePos];
        NSString *basedir = [NSString stringWithFormat:@"%@/%@", [entity basedir], [entity filename]];
        if (![entity status]) {
            // Create ccextractor arguments
            NSMutableArray *args = [[NSMutableArray new] autorelease];
            [args addObject:@"-out=srt"];           // Output SubRip files
            [args addObject:@"-o1"];                // Output custom Field 1 file
            [args addObject:[NSString stringWithFormat:@"%@/cc1.srt", basedir]];
            [args addObject:@"-o2"];                // Output custom Field 2 file
            [args addObject:[NSString stringWithFormat:@"%@/cc2.srt", basedir]];
            [args addObject:@"-utf8"];              // Encode subtitles in UTF-8
            [args addObject:@"-nofc"];              // Disable font color tags
            [args addObject:@"-noru"];              // Disable roll-up output
            [args addObject:@"-trim"];              // Trim lines
            [args addObject:@"-12"];                // Output Field 1 & Field 2 data
            [args addObject:@"--gui_mode_reports"];
            [args addObject:[NSString stringWithFormat:@"%@", [entity filepath]]];
            [_task setArguments: args];
            NSLog(@"Arguments: %@", args);
            
            // Launch ccextractor task 
            [_task setLaunchPath: _ccextractor];
            [_task launch];
            
            // Display output
            NSData *readData = nil;
            while ((readData = [readHandle availableData]) && [readData length]) {
                NSString *readString = [[NSString alloc] initWithData:readData encoding:NSASCIIStringEncoding];
                //NSLog(@"%@", readString);
            }
        } else {
            // flag view as failed
        }
        
        // Debugging
        switch ([entity status]) {
            case 1:
                NSLog(@"Error: Failed to create directory '%@'", basedir);
                break;
            case 2:
                NSLog(@"Error: Failed to generate subtitles for '%@'", [entity filepath]);
                break;
            default:
                // flag view as completed
                break;
        }

        // Increment the file pointer
        _filePos++;
    }
}

/*
 - (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
 NSInteger count = 0;
 if (self.fileQueue) {
 count = [fileQueue count];
 }
 
 return count;
 }
 
 - (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
 id returnValue=nil;
 
 NSString *columnIdentifer = [aTableColumn identifier];
 NSString *columnName = [fileQueue objectAtIndex:rowIndex];
 if ([columnIdentifer isEqualToString:@"file"]) {
 returnValue = columnName;
 }
 
 return returnValue;
 }
 
 - (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
 NSString *columnIdentifer = [aTableColumn identifier];
 
 if ([columnIdentifer isEqualToString:@"file"]) {
 [fileQueue replaceObjectAtIndex:rowIndex withObject:anObject];
 }
 
 }
 */

@end
