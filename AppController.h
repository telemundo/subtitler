//
//  Created by Rodolfo Puig on 9/24/12.
//  Copyright 2012 NBC Universal. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject <NSApplicationDelegate, NSTableViewDataSource> {
    NSWindow *_window;
    NSTableView *_tableView;
    NSMutableArray *_fileQueue;
    NSInteger _filePos;
    NSInteger _fileTotal;
    NSString *_ccextractor;
    NSTask *_task;
}

@property(assign) IBOutlet NSWindow *_window;
@property(assign) IBOutlet NSTableView *_tableView;

@property(readwrite, retain) NSMutableArray *_fileQueue;
@property(readwrite) NSInteger _filePos;
@property(readwrite) NSInteger _fileTotal;
@property(readwrite, retain) NSString *_ccextractor;
@property(readwrite, retain) NSTask *_task;

- (void)application:(NSApplication *)sender openFiles:(NSArray *)files;

- (IBAction)start:(id)sender;

@end
