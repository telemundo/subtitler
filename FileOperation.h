//
//  Created by Rodolfo Puig on 9/24/12.
//  Copyright 2012 NBC Universal. All rights reserved.
//

//#import "QRunLoopOperation.h"
//@interface FileOperation : QRunLoopOperation

@interface FileOperation : NSObject {
    NSString *     _filepath;
    NSString *     _filename;
    NSString *     _extension;
    NSString *     _basedir;
    NSString *     _status;
    NSError *      _error;
    NSURL *        _url;
    NSFileHandle * _output;
}

@property (readwrite, retain) NSString *     filepath;
@property (readwrite, retain) NSString *     filename;
@property (readwrite, retain) NSString *     extension;
@property (readwrite, retain) NSString *     basedir;
@property (readwrite, retain) NSString *     status;
@property (readwrite, retain) NSError *      error;
@property (readwrite, retain) NSURL *        url;
@property (readwrite, copy)   NSFileHandle * output;

- (id)initWithFilePath:(NSString *)filePath;
- (NSString *)outputDir;

@end