#import "CSWindow.h"
#import <QuartzCore/QuartzCore.h>

@interface CSWindow () <UIGestureRecognizerDelegate> {
    UILabel *title;
    float dragOffsetX,dragOffsetY;
}
@end

@implementation CSWindow

- (CSWindow *)initWithFrame:(CGRect)frame title:(NSString *)titleText {
    self = [super initWithFrame:frame];
    if (self){
        [self setWindowLevel:9999.0f]; //It's over NINE THOUSAND!!!
        [self setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:(2.0f / 255.0f)]];
        [self.layer setCornerRadius:10.0f];
        [self.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.layer setBorderWidth:1.0f];
        [self setClipsToBounds:YES];
        [self makeKeyAndVisible];
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(0,0,frame.size.width,43)];
        [title setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [title setText:titleText];
        [title setTextAlignment:UITextAlignmentCenter];
        [title setTextColor:[UIColor whiteColor]];
        [title setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
        [title setUserInteractionEnabled:YES];
        [title.layer setZPosition:9999.0f]; //It's over NINE THOUSAND!!!
        [self addSubview:[title autorelease]];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [panRecognizer setDelegate:self];
        [title addGestureRecognizer:panRecognizer];
        [panRecognizer release];
        
        [self attachPopUpAnimation];
    }
    return self;
}

- (void) attachPopUpAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = 0.25f;
    
    [self.layer addAnimation:animation forKey:@"popup"];
}

#pragma mark begin UIGestureRecognizer stuff

- (void)move:(UIPanGestureRecognizer *)sender {
    CGPoint translatedPoint = [sender translationInView:title];
    CGPoint convertedPoint = [self convertPoint:translatedPoint fromView:title];
    if (sender.state == UIGestureRecognizerStateBegan){
        dragOffsetX = self.center.x - convertedPoint.x;
        dragOffsetY = self.center.y - convertedPoint.y;
    }
    self.center = CGPointMake(convertedPoint.x+dragOffsetX,convertedPoint.y+dragOffsetY);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark end UIGestureRecognizer stuff

@end