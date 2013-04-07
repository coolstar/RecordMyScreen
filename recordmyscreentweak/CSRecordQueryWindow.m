#import "CSRecordQueryWindow.h"
#import <QuartzCore/QuartzCore.h>

@implementation CSRecordQueryWindow

- (CSRecordQueryWindow *)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame title:@"RecordMyScreen"];
    if (self){
        UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/RecordMyScreen/lens.png"]];
        [background setBackgroundColor:[UIColor blackColor]];
        background.frame = self.bounds;
        background.contentMode = UIViewContentModeScaleAspectFit;
        background.alpha = 0.65;
        [self addSubview:[background autorelease]];
        
        UILabel *recordMyScreenText = [[UILabel alloc] initWithFrame:CGRectMake(0,50,320,40)];
        [recordMyScreenText setText:NSLocalizedString(@"Do you wish to start recording?",@"")];
        [recordMyScreenText setTextAlignment:UITextAlignmentCenter];
        [recordMyScreenText setTextColor:[UIColor whiteColor]];
        [recordMyScreenText setLineBreakMode:UILineBreakModeWordWrap];
        [recordMyScreenText setBackgroundColor:[UIColor clearColor]];
        [self addSubview:[recordMyScreenText autorelease]];
        
        UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                               forKey:UITextAttributeFont];
        
        UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
        cancelButton.frame = CGRectMake(15,100,130,43);
        cancelButton.momentary = YES;
        cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
        cancelButton.tintColor = [UIColor grayColor];
        [cancelButton setTitleTextAttributes:attributes
                                        forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:[cancelButton autorelease]];
        
        UISegmentedControl *recordButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Record"]];
        recordButton.frame = CGRectMake(175,100,130,43);
        recordButton.momentary = YES;
        recordButton.segmentedControlStyle = UISegmentedControlStyleBar;
        recordButton.tintColor = [UIColor colorWithRed:0 green:0.75 blue:0 alpha:1];
        [recordButton setTitleTextAttributes:attributes
                                        forState:UIControlStateNormal];
        [recordButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:[recordButton autorelease]];
    }
    return self;
}

- (void)record:(id)sender {
    self.onConfirmation();
    [self close:sender];
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