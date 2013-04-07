#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <libactivator/libactivator.h>
#import "CSRecordQueryWindow.h"
#import "CSRecordCompletionAlert.h"
#import "../RecordMyScreen/CSScreenRecorder.h"

typedef void(^RecordMyScreenCallback)(void);

@interface CSRecordMyScreenListener : NSObject<LAListener,CSScreenRecorderDelegate> {
    CSScreenRecorder *_screenRecorder;
}
@end

@implementation CSRecordMyScreenListener

+(void)load {
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"org.coolstar.recordmyscreen"];
}

- (void)activator:(LAActivator *)listener receiveEvent:(LAEvent *)event
{
    if (!_screenRecorder){
        CSRecordQueryWindow *queryWindow = [[CSRecordQueryWindow alloc] initWithFrame:CGRectMake(0,0,320,150)];
        queryWindow.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
        queryWindow.onConfirmation = ^{
            _screenRecorder = [[CSScreenRecorder alloc] init];
            
            NSString *videoPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.mp4"];
            //if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"record"] boolValue]) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MM:dd:yyyy h:mm:ss a"];
                NSString *date = [dateFormatter stringFromDate:[NSDate date]];
                NSString *outName = [NSString stringWithFormat:@"Documents/%@.mp4",date];
                videoPath = [NSHomeDirectory() stringByAppendingPathComponent:outName];
                [dateFormatter release];
            //}
            
            // Set the number of audio channels
            NSNumber *audioChannels = [[NSUserDefaults standardUserDefaults] objectForKey:@"channels"];
            NSNumber *sampleRate = [[NSUserDefaults standardUserDefaults] objectForKey:@"samplerate"];
            NSString *audioPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/audio.caf"];
            
            _screenRecorder.videoOutPath = videoPath;
            _screenRecorder.audioOutPath = audioPath;
            _screenRecorder.numberOfAudioChannels = audioChannels;
            _screenRecorder.audioSampleRate = sampleRate;
            [_screenRecorder startRecordingScreen];
        };
    } else {
        [_screenRecorder stopRecordingScreen];
        CSRecordCompletionAlert *completionAlert = [[CSRecordCompletionAlert alloc] initWithFrame:CGRectMake(0,0,320,150)];
        completionAlert.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
    }
	[event setHandled:YES];
}

-(void)activator:(LAActivator *)listener abortEvent:(LAEvent *)event
{
}

- (void)screenRecorderDidStopRecording:(CSScreenRecorder *)recorder {
    [_screenRecorder release];
    _screenRecorder = nil;
}

@end;