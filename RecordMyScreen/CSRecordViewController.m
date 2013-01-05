//
//  CSRecordViewController.m
//  RecordMyScreen
//
//  Created by @coolstarorg on 12/29/12.
//  Copyright (c) 2012 CoolStar Organization. All rights reserved.
//

#import "CSRecordViewController.h"
#import <IOMobileFrameBuffer.h>
#include <sys/time.h>
#import <CoreVideo/CVPixelBuffer.h>
#import "FYCapture.h"

extern UIImage *_UICreateScreenUIImage();

@implementation CSRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Record", @"") image:[UIImage imageNamed:@"video"] tag:0] autorelease];
        _shotdir = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/shots"] retain];
        _shotQueue = [NSMutableArray new];
        _pixelBufferLock = [NSLock new];
        _fps = 24;
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
    [_record addTarget:self action:@selector(record:) forControlEvents:UIControlEventValueChanged];
    
    _stop = [[[UISegmentedControl alloc] initWithItems:@[@"Stop"]] autorelease];
    _stop.momentary = YES;
    _stop.segmentedControlStyle = UISegmentedControlStyleBar;
    _stop.tintColor = [UIColor redColor];
    _stop.enabled = NO;
    [_stop addTarget:self action:@selector(stop:) forControlEvents:UIControlEventValueChanged];
    
    _progressView.hidden = YES;
    
    
    // Check for iPad for layout
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _record.frame = CGRectMake(20, 103, 135, 33);
        _stop.frame = CGRectMake(170, 103, 135, 33);
    } else {
        _record.frame = CGRectMake(230, 150, 135, 33);
        _stop.frame = CGRectMake(400, 150, 135, 33);
    }
    
    
    [self.view addSubview:_record];
    [self.view addSubview:_stop];
    // Do any additional setup after loading the view from its nib.
}

- (void)record:(id)sender
{
    
        [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.mp4"] error:nil];
    if(!_videoWriter)
        [self setupVideoContext];
    
    
    [[NSFileManager defaultManager] removeItemAtPath:_shotdir error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:_shotdir withIntermediateDirectories:YES attributes:nil error:nil];
    
    _statusLabel.text = @"00:00:00";
    _recordStartDate = [[NSDate date] retain];
    _stop.enabled = YES;
    _record.enabled = NO;
    
    shotcount = 0;
    NSDictionary *audioSettings = @{
        AVNumberOfChannelsKey : [NSNumber numberWithInt:2]
    };
    NSError *error = nil;
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/audio.caf"];
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:path] settings:audioSettings error:&error];
    [_audioRecorder setDelegate:self];
    [_audioRecorder prepareToRecord];
    [_audioRecorder record];
    
    _recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                       target:self
                                                     selector:@selector(updateTimer:)
                                                     userInfo:nil
                                                      repeats:YES];
    
    _isRecording = TRUE;
    
    //capture loop
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //how many frames per second should we capture?
        int targetFPS = _fps;
        int msBeforeNextCapture = 1000 / targetFPS;
        
        
        struct timeval lastCapture, currentTime, startTime;
        lastCapture.tv_sec = 0;
        lastCapture.tv_usec = 0;
        
        //recording start time
        gettimeofday(&startTime, NULL);
        startTime.tv_usec /= 1000;
        
        int lastFrame = -1;
        int i=0;
        while(_isRecording)
        {
            
            //time passed since last capture
            gettimeofday(&currentTime, NULL);
            
            //convert to milliseconds to avoid overflows
            currentTime.tv_usec /= 1000;
            
            long int diff = (currentTime.tv_usec + (1000 * currentTime.tv_sec) ) - (lastCapture.tv_usec + (1000 * lastCapture.tv_sec) );
            
            if(diff >= msBeforeNextCapture)
            {
                //time since start
                long int msSinceStart = (currentTime.tv_usec + (1000 * currentTime.tv_sec) ) - (startTime.tv_usec + (1000 * startTime.tv_sec) );
                
                int frameNumber = msSinceStart / msBeforeNextCapture;
                
                CMTime frameTime = CMTimeMake(1, 1);
                CMTime lastTime=CMTimeMake(i, targetFPS);
                CMTime presentTime=CMTimeAdd(lastTime, frameTime);
                presentTime = CMTimeMake(frameNumber, targetFPS);
                
                NSParameterAssert(frameNumber != lastFrame);
                lastFrame = frameNumber;
                    
                [self captureShot:presentTime];
                i++;
                lastCapture = currentTime;
            }
        }
        
    });
}

- (void)stop:(id)sender {
    _isRecording = NO;
    _stop.enabled = NO;
    
    [_recordingTimer invalidate];
    _recordingTimer = nil;
    
    _statusLabel.text = @"Encoding Movie...";
    _progressView.hidden = NO;
    [_audioRecorder stop];
    [_audioRecorder release];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
//        CGSize size = [UIImage imageWithContentsOfFile:[_shotdir stringByAppendingString:@"/0.jpg"]].size;
//        NSDate *currentDate = [NSDate date];
//        NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:_recordStartDate];
//        [self encodeVideotoPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.mp4"] size:size duration:timeInterval];
        dispatch_async(dispatch_get_main_queue(), ^{
            _statusLabel.text = @"Ready";
            _progressView.hidden = YES;
            _record.enabled = YES;
            [[NSFileManager defaultManager] removeItemAtPath:_shotdir error:nil];
        });
    });
    
    [_recordStartDate release];
    _recordStartDate = nil;
    _audioRecorder = nil;
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self finishEncoding];
//    });
}

- (void)updateTimer:(NSTimer *)timer {
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:_recordStartDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    _statusLabel.text = timeString;
    [dateFormatter release];
}
- (void)createScreenSurface
{
    unsigned pixelFormat = 0x42475241;//'ARGB';
    int bytesPerElement = 4;
    _bytesPerRow = (bytesPerElement * _width);
    //    char *memoryRegion = "PurpleGfxMem";
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:YES], kIOSurfaceIsGlobal,
                                [NSNumber numberWithInt:bytesPerElement], kIOSurfaceBytesPerElement,
                                [NSNumber numberWithInt:_bytesPerRow], kIOSurfaceBytesPerRow,
                                [NSNumber numberWithInt:_width], kIOSurfaceWidth,
                                [NSNumber numberWithInt:_height], kIOSurfaceHeight,
                                [NSNumber numberWithUnsignedInt:pixelFormat], kIOSurfacePixelFormat,
                                [NSNumber numberWithInt:_bytesPerRow * _height], kIOSurfaceAllocSize,
                                //@"PurpleGfxMem", kIOSurfaceMemoryRegion,
                                nil];
    _surface = IOSurfaceCreate((CFDictionaryRef)properties);
}
void CARenderServerRenderDisplay( kern_return_t a, CFStringRef b, IOSurfaceRef surface, int x, int y);
- (void)captureShot:(CMTime)frameTime
{
    
    if(!_surface)
        [self createScreenSurface];

    IOSurfaceLock(_surface, 0, nil);
    CARenderServerRenderDisplay(0, CFSTR("LCD"), _surface, 0, 0);
    IOSurfaceUnlock(_surface, 0, 0);

    void *baseAddr = IOSurfaceGetBaseAddress(_surface);
    int totalBytes = _bytesPerRow * _height;
    void *rawData = malloc(totalBytes);
    memcpy(rawData, baseAddr, totalBytes);
    
    int thisShot = shotcount;
    shotcount++;
    
    
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    dispatch_async(dispatch_get_main_queue(), ^{
        CVPixelBufferRef pixelBuffer = NULL;
        if(!_pixelBufferAdaptor.pixelBufferPool){
            free(rawData);
            return;
        }
        NSParameterAssert(_pixelBufferAdaptor.pixelBufferPool != NULL);
        [_pixelBufferLock lock];
        CVPixelBufferPoolCreatePixelBuffer (kCFAllocatorDefault, _pixelBufferAdaptor.pixelBufferPool, &pixelBuffer);
        [_pixelBufferLock unlock];
        NSParameterAssert(pixelBuffer != NULL);
        
        //unlock pixel buffer data
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        void *pixelData = CVPixelBufferGetBaseAddress(pixelBuffer);
        NSParameterAssert(pixelData != NULL);
        
        //copy over raw image data and free
        memcpy(pixelData, rawData, totalBytes);
        free(rawData);
        
        //unlock pixel buffer data
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            

            if(_isRecording && _videoWriterInput.readyForMoreMediaData)
            {
                NSLog(@"appending @ frame %lld", frameTime.value);
                [_pixelBufferLock lock];
                [_pixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:frameTime];
                CVPixelBufferRelease(pixelBuffer);
                [_pixelBufferLock unlock];
            }
            else
            {
                FYCapture *cap = [[FYCapture alloc] initWithPixelBuffer:pixelBuffer frameTime:frameTime];
                [_shotQueue addObject:cap];
                [cap release];
            }
            if(!_isRecording && thisShot == (shotcount - 1))
                [self finishEncoding];
        });
    });

    
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

-(void)dealloc {
    [_shotQueue release];
    CFRelease(_surface);
    [_shotdir release];
    [super dealloc];
}
- (void)setupVideoContext
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    float scale = [UIScreen mainScreen].scale;
    _width = screenRect.size.width * scale;
    _height = screenRect.size.height * scale;
    
    NSString *outPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.mp4"];
    
    NSError *error = nil;
    
    _videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:outPath]
                                                           fileType:AVFileTypeMPEG4
                                                              error:&error];
    
    if(error)
    {
        NSLog(@"error: %@", error);
        return;
    }
    NSParameterAssert(_videoWriter);
    
    NSMutableDictionary * compressionProperties = [NSMutableDictionary dictionary];
    [compressionProperties setObject: [NSNumber numberWithInt: 1000000] forKey: AVVideoAverageBitRateKey];
    [compressionProperties setObject: [NSNumber numberWithInt: _fps] forKey: AVVideoMaxKeyFrameIntervalKey];
    //[compressionProperties setObject: AVVideoProfileLevelH264Main31 forKey: AVVideoProfileLevelKey];
    [compressionProperties setObject: AVVideoProfileLevelH264Main41 forKey: AVVideoProfileLevelKey];
    
    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:_width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:_height], AVVideoHeightKey,
                                   compressionProperties, AVVideoCompressionPropertiesKey,
                                   nil];
    
    NSParameterAssert([_videoWriter canApplyOutputSettings:outputSettings forMediaType:AVMediaTypeVideo]);
    
    _videoWriterInput = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                          outputSettings:outputSettings] retain];
    

    NSParameterAssert(_videoWriterInput);
    NSParameterAssert([_videoWriter canAddInput:_videoWriterInput]);
    [_videoWriter addInput:_videoWriterInput];
    
    NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                      [NSNumber numberWithInt:_width], kCVPixelBufferWidthKey,
                                      [NSNumber numberWithInt:_height], kCVPixelBufferHeightKey,
                                      kCFAllocatorDefault, kCVPixelBufferMemoryAllocatorKey,
                                      nil];
    
    _pixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoWriterInput
                                                                                                                     sourcePixelBufferAttributes:bufferAttributes];
    [_pixelBufferAdaptor retain];
    
    //FPS
    _videoWriterInput.mediaTimeScale = _fps;
    _videoWriter.movieTimeScale = _fps;
    
    //Start a session:
    [_videoWriterInput setExpectsMediaDataInRealTime:YES];
    [_videoWriter startWriting];
    [_videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    NSParameterAssert(_pixelBufferAdaptor.pixelBufferPool != NULL);
    
}
-(void)finishEncoding
{
    
    NSLog(@"shots queued: %d", _shotQueue.count);
    
    while([_shotQueue count])
    {
        if(_videoWriterInput.readyForMoreMediaData)
        {
            FYCapture *cap = [_shotQueue objectAtIndex:0];
            [_pixelBufferLock lock];
            [_pixelBufferAdaptor appendPixelBuffer:cap.buffer withPresentationTime:cap.frameTime];
            CVPixelBufferRelease(cap.buffer);
            [_shotQueue removeObject:cap];
            [_pixelBufferLock unlock];
        }
    }

    [_videoWriterInput markAsFinished];
    [_videoWriter finishWriting];
    
    CVPixelBufferPoolRelease(_pixelBufferAdaptor.pixelBufferPool);
    [_videoWriter release];
    [_videoWriterInput release];
    [_pixelBufferAdaptor release];
    _videoWriter = nil;
    _videoWriterInput = nil;
    _pixelBufferAdaptor = nil;
    
    NSLog (@"Done");
}


@end
