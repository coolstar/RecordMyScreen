//
//  SAResizibleBubble.m
//
// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2013 Andrei Solovjev - http://solovjev.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SAResizibleBubble.h"

@implementation SAResizibleBubble

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* bubbleGradientTop = [UIColor colorWithRed: 1 green: 0.939 blue: 0.743 alpha: 1];
    UIColor* bubbleGradientBottom = [UIColor colorWithRed: 1 green: 0.817 blue: 0.053 alpha: 1];
    UIColor* bubbleHighlightColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* bubbleStrokeColor = [UIColor colorWithRed: 0.173 green: 0.173 blue: 0.173 alpha: 1];
    
    //// Gradient Declarations
    NSArray* bubbleGradientColors = [NSArray arrayWithObjects:
                                     (id)bubbleGradientTop.CGColor,
                                     (id)bubbleGradientBottom.CGColor, nil];
    CGFloat bubbleGradientLocations[] = {0, 1};
    CGGradientRef bubbleGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)bubbleGradientColors, bubbleGradientLocations);
    
    //// Shadow Declarations
    UIColor* outerShadow = [UIColor blackColor];
    CGSize outerShadowOffset = CGSizeMake(0.1, 6.1);
    CGFloat outerShadowBlurRadius = 13;
    UIColor* highlightShadow = bubbleHighlightColor;
    CGSize highlightShadowOffset = CGSizeMake(0.1, 2.1);
    CGFloat highlightShadowBlurRadius = 0;
    
    //// Frames
    CGRect bubbleFrame = self.bounds;
    
    //// Subframes
    CGRect arrowFrame = CGRectMake(CGRectGetMinX(bubbleFrame) + floor((CGRectGetWidth(bubbleFrame) - 59) * 0.50462 + 0.5), CGRectGetMinY(bubbleFrame) + CGRectGetHeight(bubbleFrame) - 46, 59, 46);
    
    
    //// Bubble Drawing
    UIBezierPath* bubblePath = [UIBezierPath bezierPath];
    [bubblePath moveToPoint: CGPointMake(CGRectGetMaxX(bubbleFrame) - 12, CGRectGetMinY(bubbleFrame) + 28.5)];
    [bubblePath addLineToPoint: CGPointMake(CGRectGetMaxX(bubbleFrame) - 12, CGRectGetMaxY(bubbleFrame) - 27.5)];
    [bubblePath addCurveToPoint: CGPointMake(CGRectGetMaxX(bubbleFrame) - 25, CGRectGetMaxY(bubbleFrame) - 14.5) controlPoint1: CGPointMake(CGRectGetMaxX(bubbleFrame) - 12, CGRectGetMaxY(bubbleFrame) - 20.32) controlPoint2: CGPointMake(CGRectGetMaxX(bubbleFrame) - 17.82, CGRectGetMaxY(bubbleFrame) - 14.5)];
    [bubblePath addLineToPoint: CGPointMake(CGRectGetMinX(arrowFrame) + 40.5, CGRectGetMaxY(arrowFrame) - 13.5)];
    [bubblePath addLineToPoint: CGPointMake(CGRectGetMinX(arrowFrame) + 29.5, CGRectGetMaxY(arrowFrame) - 0.5)];
    [bubblePath addLineToPoint: CGPointMake(CGRectGetMinX(arrowFrame) + 18.5, CGRectGetMaxY(arrowFrame) - 13.5)];
    [bubblePath addLineToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 26.5, CGRectGetMaxY(bubbleFrame) - 14.5)];
    [bubblePath addCurveToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 13.5, CGRectGetMaxY(bubbleFrame) - 27.5) controlPoint1: CGPointMake(CGRectGetMinX(bubbleFrame) + 19.32, CGRectGetMaxY(bubbleFrame) - 14.5) controlPoint2: CGPointMake(CGRectGetMinX(bubbleFrame) + 13.5, CGRectGetMaxY(bubbleFrame) - 20.32)];
    [bubblePath addLineToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 13.5, CGRectGetMinY(bubbleFrame) + 28.5)];
    [bubblePath addCurveToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 26.5, CGRectGetMinY(bubbleFrame) + 15.5) controlPoint1: CGPointMake(CGRectGetMinX(bubbleFrame) + 13.5, CGRectGetMinY(bubbleFrame) + 21.32) controlPoint2: CGPointMake(CGRectGetMinX(bubbleFrame) + 19.32, CGRectGetMinY(bubbleFrame) + 15.5)];
    [bubblePath addLineToPoint: CGPointMake(CGRectGetMaxX(bubbleFrame) - 25, CGRectGetMinY(bubbleFrame) + 15.5)];
    [bubblePath addCurveToPoint: CGPointMake(CGRectGetMaxX(bubbleFrame) - 12, CGRectGetMinY(bubbleFrame) + 28.5) controlPoint1: CGPointMake(CGRectGetMaxX(bubbleFrame) - 17.82, CGRectGetMinY(bubbleFrame) + 15.5) controlPoint2: CGPointMake(CGRectGetMaxX(bubbleFrame) - 12, CGRectGetMinY(bubbleFrame) + 21.32)];
    [bubblePath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, outerShadowOffset, outerShadowBlurRadius, outerShadow.CGColor);
    CGContextBeginTransparencyLayer(context, NULL);
    [bubblePath addClip];
    CGRect bubbleBounds = CGPathGetPathBoundingBox(bubblePath.CGPath);
    CGContextDrawLinearGradient(context, bubbleGradient,
                                CGPointMake(CGRectGetMidX(bubbleBounds), CGRectGetMinY(bubbleBounds)),
                                CGPointMake(CGRectGetMidX(bubbleBounds), CGRectGetMaxY(bubbleBounds)),
                                0);
    CGContextEndTransparencyLayer(context);
    
    ////// Bubble Inner Shadow
    CGRect bubbleBorderRect = CGRectInset([bubblePath bounds], -highlightShadowBlurRadius, -highlightShadowBlurRadius);
    bubbleBorderRect = CGRectOffset(bubbleBorderRect, -highlightShadowOffset.width, -highlightShadowOffset.height);
    bubbleBorderRect = CGRectInset(CGRectUnion(bubbleBorderRect, [bubblePath bounds]), -1, -1);
    
    UIBezierPath* bubbleNegativePath = [UIBezierPath bezierPathWithRect: bubbleBorderRect];
    [bubbleNegativePath appendPath: bubblePath];
    bubbleNegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = highlightShadowOffset.width + round(bubbleBorderRect.size.width);
        CGFloat yOffset = highlightShadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    highlightShadowBlurRadius,
                                    highlightShadow.CGColor);
        
        [bubblePath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(bubbleBorderRect.size.width), 0);
        [bubbleNegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [bubbleNegativePath fill];
    }
    CGContextRestoreGState(context);
    
    CGContextRestoreGState(context);
    
    [bubbleStrokeColor setStroke];
    bubblePath.lineWidth = 1;
    [bubblePath stroke];
    
    
    //// Cleanup
    CGGradientRelease(bubbleGradient);
    CGColorSpaceRelease(colorSpace);
    
    
    
}


@end
