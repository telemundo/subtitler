//
//  Subtitle.m
//  Subtitler
//
//  Created by Rodolfo Puig on 9/24/12.
//  Copyright 2012 NBC Universal. All rights reserved.
//

#import "Subtitle.h"


@implementation Subtitle

@synthesize filename;
@synthesize subformat;
@synthesize finished;

- (void) dealloc {
    self.filename = nil;
    self.subformat = nil;
    [super dealloc];
}

@end
