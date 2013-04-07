#import "CSRecordCompletionAlert.h"
#import <QuartzCore/QuartzCore.h>

@implementation CSRecordCompletionAlert

- (CSRecordCompletionAlert *)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame title:@"RecordMyScreen"];
    if (self){
        UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/RecordMyScreen/lens.png"]];
        [background setBackgroundColor:[UIColor blackColor]];
        background.frame = self.bounds;
        background.contentMode = UIViewContentModeScaleAspectFit;
        background.alpha = 0.65;
        [self addSubview:[background autorelease]];
        
        UILabel *recordMyScreenText = [[UILabel alloc] initWithFrame:CGRectMake(0,50,320,40)];
        [recordMyScreenText setText:NSLocalizedString(@"Recording saved sucessfully.",@"")];
        [recordMyScreenText setTextAlignment:UITextAlignmentCenter];
        [recordMyScreenText setTextColor:[UIColor whiteColor]];
        [recordMyScreenText setLineBreakMode:UILineBreakModeWordWrap];
        [recordMyScreenText setBackgroundColor:[UIColor clearColor]];
        [self addSubview:[recordMyScreenText autorelease]];
        
        UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                               forKey:UITextAttributeFont];
        
        UISegmentedControl *okButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"OK"]];
        okButton.frame = CGRectMake(15,100,290,43);
        okButton.momentary = YES;
        okButton.segmentedControlStyle = UISegmentedControlStyleBar;
        okButton.tintColor = [UIColor grayColor];
        [okButton setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
        [okButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:[okButton autorelease]];
    }
    return self;
}

- (void)close:(id)sender {
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [self setAlpha:0];
                     } completion:^(BOOL finished){
                         [self resignKeyWindow];
                         [self setHidden:YES];
                         [self release];
                     }];
}

- (void)dealloc {
    [super dealloc];
}

@end