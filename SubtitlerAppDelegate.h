//
//  SubtitlerAppDelegate.h
//  Subtitler
//
//  Created by Rodolfo Puig on 9/24/12.
//  Copyright 2012 NBC Universal. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SubtitlerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

- (void)application:(NSApplication *)sender openFiles:(NSArray *) files;

@end
