//
//  CSRecordViewController.m
//  RecordMyScreen
//
//  Created by @coolstarorg on 12/29/12.
//  Copyright (c) 2012 CoolStar Organization. All rights reserved.
//

#import "CSRecordViewController.h"

extern UIImage* _UICreateScreenUIImage();

@interface CSRecordViewController ()

@end

@implementation CSRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Record", @"") image:[UIImage imageNamed:@"video"] tag:0] autorelease];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _record = [[[UISegmentedControl alloc] initWithItems:@[@"Record"]] autorelease];
    _record.momentary = YES;
    _record.segmentedControlStyle = UISegmentedControlStyleBar;
    _record.tintColor = [UIColor greenColor];
    _record.frame = CGRectMake(20, 98, 135, 33);
    [_record addTarget:self action:@selector(record:) forControlEvents:UIControlEventValueChanged];
    
    _stop = [[[UISegmentedControl alloc] initWithItems:@[@"Stop"]] autorelease];
    _stop.momentary = YES;
    _stop.segmentedControlStyle = UISegmentedControlStyleBar;
    _stop.tintColor = [UIColor redColor];
    _stop.frame = CGRectMake(170, 98, 135, 33);
    _stop.enabled = NO;
    [_stop addTarget:self action:@selector(stop:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_record];
    [self.view addSubview:_stop];
    // Do any additional setup after loading the view from its nib.
}

- (void)record:(id)sender {
    _stop.enabled = YES;
    _record.enabled = NO;
    
    shotcount = 0;
    NSDictionary *audioSettings = @{
        AVFormatIDKey : [NSNumber numberWithInt:kAudioFormatLinearPCM],
        AVNumberOfChannelsKey : [NSNumber numberWithInt:2],
        AVSampleRateKey : [NSNumber numberWithFloat:44100.0f],
        AVLinearPCMBitDepthKey : [NSNumber numberWithInt:16],
        AVLinearPCMIsBigEndianKey : [NSNumber numberWithBool:NO],
        AVLinearPCMIsFloatKey : [NSNumber numberWithBool:NO]
    };
    NSError *error = nil;
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/audio.wav"];
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:path] settings:audioSettings error:&error];
    [_audioRecorder setDelegate:self];
    [_audioRecorder prepareToRecord];
    [_audioRecorder record];
}

- (void)stop:(id)sender {
    _stop.enabled = NO;
    _record.enabled = YES;
    
    [_audioRecorder stop];
    [_audioRecorder release];
    _audioRecorder = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
