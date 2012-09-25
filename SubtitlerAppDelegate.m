//
//  SubtitlerAppDelegate.m
//  Subtitler
//
//  Created by Rodolfo Puig on 9/24/12.
//  Copyright 2012 NBC Universal. All rights reserved.
//

#import "SubtitlerAppDelegate.h"


@implementation SubtitlerAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    movies = [[NSMutableArray alloc] initWithObjects: @"cea608_field1.mpg", @"cea708ntsc_field1.mpg", @"cea708dtvntsc_field1.mpg", @"cea708_dtv.mpg", @"dvd_field1.mpg", @"scte20_field1.mpg", nil];
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *) files {
    for (NSString *filename in files) {
        NSLog(@"Accepted file: %@", filename);
    }
}

- (IBAction)run:(id)sender {
    if ([movies count]) {
        task = [[NSTask alloc] init];

        // Create pipes
        NSPipe *stdout = [NSPipe pipe];
        NSPipe *stderr = [NSPipe pipe];
        [task setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
        [task setStandardOutput:stdout];
        [task setStandardError:stderr];
        NSFileHandle *readHandle = [[task standardError] fileHandleForReading];

        // Locate task binary
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ccextractor"];
        [task setLaunchPath: path];

        // Create task arguments
        NSMutableArray *args = [[NSMutableArray new] autorelease];
        //[args addObject:[NSString stringWithFormat:@"-o1 %@", sub1]];
        //[args addObject:[NSString stringWithFormat:@"-o2 %@", sub2]];
        [args addObject:@"-out=srt"];           // Output SubRip files
        [args addObject:@"-utf8"];              // Encode subtitles in UTF-8
        [args addObject:@"-nofc"];              // Disable font color tags
        [args addObject:@"-noru"];              // Disable roll-up output
        [args addObject:@"-trim"];              // Trim lines
        [args addObject:@"-12"];                // Output Field 1 & Field 2 data
        [args addObject:@"--gui_mode_reports"];
        [args addObject:[NSString stringWithFormat:@"/Users/Rudisimo/Development/cc/%@", [movies objectAtIndex:0]]];
        [task setArguments: args];
        NSLog(@"Arguments: %@", args);

        // Launch task 
        [task launch];

        // Display output
        NSData *readData=nil;
        while ((readData = [readHandle availableData]) && [readData length]) {
            NSString *readString = [[NSString alloc] initWithData:readData encoding:NSASCIIStringEncoding];
            NSLog(@"Output: %@", readString);
        }

        // Go to the next movie
        [movies removeObjectAtIndex:0];
    }
}

@end
