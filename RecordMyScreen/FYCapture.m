//
//  FYCapture.m
//  RecordMyScreen
//
//  Created by John Coates on 1/4/13.
//  Copyright (c) 2013 CoolStar Organization. All rights reserved.
//

#import "FYCapture.h"

@implementation FYCapture

@synthesize buffer=_buffer, bytes=_bytes, frameTime=_frameTime;

- (id)initWithPixelBuffer:(CVPixelBufferRef)buffer frameTime:(CMTime)frameTime
{
    if(self = [super init])
    {
        _buffer = buffer;
        _frameTime = frameTime;
    }
    
    return self;
}
@end
