//
//  CSRecordingListViewController.h
//  RecordMyScreen
//
//  Created by @coolstarorg on 12/30/12.
//  Copyright (c) 2012 CoolStar Organization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SAVideoRangeSlider.h"


@interface CSRecordingListViewController : UITableViewController<SAVideoRangeSliderDelegate> {
    NSMutableArray *_folderItems;
    CGFloat startTime;
    CGFloat stopTime;
    BOOL isEditing;
    int row;
    SAVideoRangeSlider *mySAVideoRangeSlider;
    UIButton *ok;
}

@end
