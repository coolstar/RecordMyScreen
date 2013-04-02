//
//  CSRecordViewController.h
//  RecordMyScreen
//
//  Created by @coolstarorg on 12/29/12.
//  Copyright (c) 2012 CoolStar Organization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "CSScreenRecorder.h"


@interface CSRecordViewController : UIViewController <CSScreenRecorderDelegate>
{
    UISegmentedControl      *_record, *_stop;
    IBOutlet UIImageView    *_recordbar;
    IBOutlet UILabel        *_statusLabel;
    IBOutlet UIProgressView *_progressView;

}
@end
