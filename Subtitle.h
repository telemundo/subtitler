//
//  Subtitle.h
//  Subtitler
//
//  Created by Rodolfo Puig on 9/24/12.
//  Copyright 2012 NBC Universal. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Subtitle : NSObject {
    NSString * filename;
    NSString * subformat;
    BOOL finished;
}

@property (retain) NSString * filename;
@property (retain) NSString * subformat;
@property (readonly, getter=isFinished) BOOL finished;

@end
