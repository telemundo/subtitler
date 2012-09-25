//
//  Created by Rodolfo Puig on 9/24/12.
//  Copyright 2012 NBC Universal. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FileEntity : NSObject {
@private
    NSInteger _status;
    NSString *_basedir;
    NSString *_filepath;
    NSString *_filename;
    NSString *_extension;
    NSURL *_url;
}

- (id)init:(NSString *)file;

@property(readwrite) NSInteger status;
@property(readwrite, retain) NSString *basedir;
@property(readwrite, retain) NSString *filepath;
@property(readwrite, retain) NSString *filename;
@property(readwrite, retain) NSString *extension;
@property(readwrite, retain) NSURL *url;

@end
