//
//  CSRecordViewController.h
//  RecordMyScreen
//
//  Created by @coolstarorg on 12/29/12.
//  Copyright (c) 2012 CoolStar Organization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSRecordViewController : UIViewController {
    UISegmentedControl *_record,*_stop;
    IBOutlet UIImageView *_recordbar;
    NSTimer *_recordingTimer;
    
}

@end
