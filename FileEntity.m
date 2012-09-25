//
//  Created by Rodolfo Puig on 9/24/12.
//  Copyright 2012 NBC Universal. All rights reserved.
//

#import "FileEntity.h"

@implementation FileEntity

@synthesize status = _status;
@synthesize basedir = _basedir;
@synthesize filepath = _filepath;
@synthesize filename = _filename;
@synthesize extension = _extension;
@synthesize url = _url;

- (id)init:(NSString *)file {
    if (self = [super init]) {
        self.status = 0;
        self.filepath = [[file retain] stringByExpandingTildeInPath];
        self.basedir = [self.filepath stringByDeletingLastPathComponent];
        self.filename = [[self.filepath lastPathComponent] stringByDeletingPathExtension];
        self.extension = [self.filepath pathExtension];
        self.url = [NSURL fileURLWithPath:self.filepath];
    }
    return self;
}

- (void) dealloc {
    [_basedir release];
    [_filepath release];
    [_filename release];
    [_extension release];
    [_url release];
    [super dealloc];
}

@end
