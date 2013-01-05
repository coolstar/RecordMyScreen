//
//  FYCapture.h
//  RecordMyScreen
//
//  Created by John Coates on 1/4/13.
//  Copyright (c) 2013 CoolStar Organization. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@interface FYCapture : NSObject
{
    CVPixelBufferRef _buffer;
    int _bytes;
    CMTime _frameTime;
}

@property (readonly) CVPixelBufferRef buffer;
@property (readonly) int bytes;
@property (readonly) CMTime frameTime;

- (id)initWithPixelBuffer:(CVPixelBufferRef)buffer frameTime:(CMTime)frameTime;
@end
