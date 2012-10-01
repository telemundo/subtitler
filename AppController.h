//
//  Created by Rodolfo Puig on 9/24/12.
//  Copyright 2012 NBC Universal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileOperation.h"

@interface AppController : NSObject <NSApplicationDelegate, NSTableViewDataSource> {
    NSWindow *       _window;
    NSTableView *    _tableView;
    NSFileManager *  _fileManager;
    NSMutableArray * _fileQueue;
    NSInteger        _filePos;
    NSInteger        _fileTotal;
    NSString *       _ccextractor;
    NSTask *         _cctask;
    BOOL             _isRunning;
}

@property (assign) IBOutlet NSWindow *         window;
@property (assign) IBOutlet NSTableView *      tableView;
@property (readwrite, retain) NSFileManager *  fileManager;
@property (readwrite, retain) NSMutableArray * fileQueue;
@property (readwrite        ) NSInteger        filePos;
@property (readwrite        ) NSInteger        fileTotal;
@property (readwrite, retain) NSString *       ccextractor;
@property (readwrite, retain) NSTask *         cctask;
@property (readwrite        ) BOOL             isRunning;

- (IBAction)start:(id)sender;
- (void)application:(NSApplication *)sender openFiles:(NSArray *)files;
- (void)processFiles;
- (void)nextFile;
- (void)export:(FileOperation *)entity;

@end