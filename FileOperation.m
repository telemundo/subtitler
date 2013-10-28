//
//  Created by Rodolfo Puig on 9/24/12.
//  Copyright 2012 NBC Universal. All rights reserved.
//

#import "FileOperation.h"

@implementation FileOperation

@synthesize filepath  = _filepath;
@synthesize filename  = _filename;
@synthesize extension = _extension;
@synthesize basedir   = _basedir;
@synthesize status    = _status;
@synthesize error     = _error;
@synthesize url       = _url;
@synthesize output    = _output;

- (id)initWithFilePath:(NSString *)filePath {
    assert(filePath != nil);

    if (self = [super init]) {
        self.filepath  = [[filePath retain] stringByExpandingTildeInPath];
        self.filename  = [[self.filepath lastPathComponent] stringByDeletingPathExtension];
        self.extension = [self.filepath pathExtension];
        self.basedir   = [self.filepath stringByDeletingLastPathComponent];
        self.url       = [NSURL fileURLWithPath:self.filepath];
    }

    return self;
}

- (void)dealloc {
    [_filepath release];
    [_filename release];
    [_extension release];
    [_basedir release];
    [_status release];
    [_error release];
    [_url release];
    [_output release];
    [super dealloc];
}

- (NSString *)outputDir {
    assert(_basedir != nil);
    assert(_filename != nil);
    
    return [NSString stringWithFormat:@"%@/%@", _basedir, _filename];
}

@end
