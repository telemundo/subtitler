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
	// Insert code here to initialize your application 
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *) files {
    for (NSString *filename in files) {
        NSLog(@"Accepted file: %@", filename);
    }
}

@end
