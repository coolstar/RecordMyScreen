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

@implementation CSRecordViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Record", @"") image:[UIImage imageNamed:@"video"] tag:0] autorelease];
        _pixelBufferLock = [NSLock new];
        
        //video queue
        _video_queue = dispatch_queue_create("video_queue", DISPATCH_QUEUE_SERIAL);
        //frame rate
        _fps = 24;
        //encoding kbps
        _kbps = 5000;
    }
    return self;
}
-(void)dealloc {
    dispatch_release(_video_queue);
    CFRelease(_surface);
    [super dealloc];
}

#pragma mark - UI
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _record = [[[UISegmentedControl alloc] initWithItems:@[@"Record"]] autorelease];
    _record.momentary = YES;
    _record.segmentedControlStyle = UISegmentedControlStyleBar;
    _record.tintColor = [UIColor greenColor];
    [_record setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [_record addTarget:self action:@selector(record:) forControlEvents:UIControlEventValueChanged];
    
    _stop = [[[UISegmentedControl alloc] initWithItems:@[@"Stop"]] autorelease];
    _stop.momentary = YES;
    _stop.segmentedControlStyle = UISegmentedControlStyleBar;
    _stop.tintColor = [UIColor redColor];
    _stop.enabled = NO;
    [_stop setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
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
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

#pragma mark - Starting / Stopping

- (void)record: (id)sender
{
    // Remove the old video
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.mp4"] error:nil];
    
    // if the AVAssetWriter is NOT valid, setup video context
    if(!_videoWriter)
        [self setupVideoContext];
    
    // Update the UI
    _statusLabel.text = @"00:00:00";
    _recordStartDate = [[NSDate date] retain];
    _stop.enabled = YES;
    _record.enabled = NO;
	
    // Setup to be able to record global sounds (preexisting app sounds)
	NSError *sessionError = nil;
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(setCategory:withOptions:error:)])
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDuckOthers error:&sessionError];
    else
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    // Set the audio session to be active
	[[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    
    // Set the number of audio channels
    NSNumber *audioChannels = [[NSUserDefaults standardUserDefaults] objectForKey:@"channels"];
    NSNumber *sampleRate = [[NSUserDefaults standardUserDefaults] objectForKey:@"samplerate"];
    NSDictionary *audioSettings = @{
    AVNumberOfChannelsKey : audioChannels ? audioChannels : [NSNumber numberWithInt:2],
    AVSampleRateKey : sampleRate ? sampleRate : [NSNumber numberWithFloat:44100.0f]
    };
    
    // Set output path of the audio file
    NSError *error = nil;
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/audio.caf"];
    
    // Initialize the audio recorder
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:path] settings:audioSettings error:&error];
    [_audioRecorder setDelegate:self];
    [_audioRecorder prepareToRecord];
    
    // Start recording :P
    [_audioRecorder record];
    
    // Set timer to update the record time label
    _recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                       target:self
                                                     selector:@selector(updateTimer:)
                                                     userInfo:nil
                                                      repeats:YES];
    
    _isRecording = TRUE;
    
    //capture loop (In another thread)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int targetFPS = _fps;
        int msBeforeNextCapture = 1000 / targetFPS;
        
        struct timeval lastCapture, currentTime, startTime;
        lastCapture.tv_sec = 0;
        lastCapture.tv_usec = 0;
        
        //recording start time
        gettimeofday(&startTime, NULL);
        startTime.tv_usec /= 1000;
        
        int lastFrame = -1;
        while(_isRecording)
        {
            //time passed since last capture
            gettimeofday(&currentTime, NULL);
            
            //convert to milliseconds to avoid overflows
            currentTime.tv_usec /= 1000;
            
            unsigned long long diff = (currentTime.tv_usec + (1000 * currentTime.tv_sec) ) - (lastCapture.tv_usec + (1000 * lastCapture.tv_sec) );
            
            // if enough time has passed, capture another shot
            if(diff >= msBeforeNextCapture)
            {
                //time since start
                long int msSinceStart = (currentTime.tv_usec + (1000 * currentTime.tv_sec) ) - (startTime.tv_usec + (1000 * startTime.tv_sec) );
                
                // Generate the frame number
                int frameNumber = msSinceStart / msBeforeNextCapture;
                CMTime presentTime;
                presentTime = CMTimeMake(frameNumber, targetFPS);
                
                // Frame number cannot be last frames number :P
                NSParameterAssert(frameNumber != lastFrame);
                lastFrame = frameNumber;
                
                // Capture next shot and repeat
                [self captureShot:presentTime];
                lastCapture = currentTime;
            }
        }
        
        // finish encoding, using the video_queue thread
        dispatch_async(_video_queue, ^{
            [self finishEncoding];
        });
        
    });
}

- (void)stop: (id)sender {
    // Set the flag to stop recording
    _isRecording = NO;
    
    // Disable the stop button
    _stop.enabled = NO;
    
    // Invalidate the recording time
    [_recordingTimer invalidate];
    _recordingTimer = nil;
    
    // Announce Encoding will begin
    _statusLabel.text = @"Encoding Movie...";
    
    // Show progress view
    _progressView.hidden = NO;
    
    // Stop the audio recording
    [_audioRecorder stop];
    [_audioRecorder release];
    
    // Update the UI for another round
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            _statusLabel.text = @"Ready";
            _progressView.hidden = YES;
            _record.enabled = YES;
        });
    });
    
    [_recordStartDate release];
    _recordStartDate = nil;
    _audioRecorder = nil;
}

- (void)updateTimer:(NSTimer *)timer {
    // Get the current date
    NSDate *currentDate = [NSDate date];
    
    // Current time
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:_recordStartDate];
    
    // Get date from when the recording started
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Make a date formatter (Possibly reuse instead of creating each time)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    // Set the current time since recording began
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    _statusLabel.text = timeString;
    [dateFormatter release];
}

#pragma mark - Capturing

- (void)createScreenSurface
{
    // Pixel format for Alpha Red Green Blue
    unsigned pixelFormat = 0x42475241;//'ARGB';
    
    // 4 Bytes per pixel
    int bytesPerElement = 4;
    
    // Bytes per row
    _bytesPerRow = (bytesPerElement * _width);
    
    // Properties include: SurfaceIsGlobal, BytesPerElement, BytesPerRow, SurfaceWidth, SurfaceHeight, PixelFormat, SurfaceAllocSize (space for the entire surface)
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:YES], kIOSurfaceIsGlobal,
                                [NSNumber numberWithInt:bytesPerElement], kIOSurfaceBytesPerElement,
                                [NSNumber numberWithInt:_bytesPerRow], kIOSurfaceBytesPerRow,
                                [NSNumber numberWithInt:_width], kIOSurfaceWidth,
                                [NSNumber numberWithInt:_height], kIOSurfaceHeight,
                                [NSNumber numberWithUnsignedInt:pixelFormat], kIOSurfacePixelFormat,
                                [NSNumber numberWithInt:_bytesPerRow * _height], kIOSurfaceAllocSize,
                                nil];
    
    // This is the current surface
    _surface = IOSurfaceCreate((CFDictionaryRef)properties);
}

- (void)captureShot:(CMTime)frameTime
{
    // Create an IOSurfaceRef if one does not exist
    if(!_surface)
        [self createScreenSurface];
    
    // Lock the surface from other threads
    static NSMutableArray * buffers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        buffers = [[NSMutableArray alloc] init];
    });
    
    IOSurfaceLock(_surface, 0, nil);
    // Take currently displayed image from the LCD
    CARenderServerRenderDisplay(0, CFSTR("LCD"), _surface, 0, 0);
    // Unlock the surface
    IOSurfaceUnlock(_surface, 0, 0);
    
    // Make a raw memory copy of the surface
    void *baseAddr = IOSurfaceGetBaseAddress(_surface);
    int totalBytes = _bytesPerRow * _height;
    
    //void *rawData = malloc(totalBytes);
    //memcpy(rawData, baseAddr, totalBytes);
    NSMutableData * rawDataObj = nil;
    if (buffers.count == 0)
        rawDataObj = [[NSMutableData dataWithBytes:baseAddr length:totalBytes] retain];
    else @synchronized(buffers) {
        rawDataObj = [buffers lastObject];
        memcpy((void *)[rawDataObj bytes], baseAddr, totalBytes);
        //[rawDataObj replaceBytesInRange:NSMakeRange(0, rawDataObj.length) withBytes:baseAddr length:totalBytes];
        [buffers removeLastObject];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(!_pixelBufferAdaptor.pixelBufferPool){
            NSLog(@"skipping frame: %lld", frameTime.value);
            //free(rawData);
            @synchronized(buffers) {
                //[buffers addObject:rawDataObj];
            }
            return;
        }
        
        static CVPixelBufferRef pixelBuffer = NULL;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSParameterAssert(_pixelBufferAdaptor.pixelBufferPool != NULL);
            [_pixelBufferLock lock];
            CVPixelBufferPoolCreatePixelBuffer (kCFAllocatorDefault, _pixelBufferAdaptor.pixelBufferPool, &pixelBuffer);
            [_pixelBufferLock unlock];
            NSParameterAssert(pixelBuffer != NULL);
        });
        
        //unlock pixel buffer data
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        void *pixelData = CVPixelBufferGetBaseAddress(pixelBuffer);
        NSParameterAssert(pixelData != NULL);
        
        //copy over raw image data and free
        memcpy(pixelData, [rawDataObj bytes], totalBytes);
        //free(rawData);
        @synchronized(buffers) {
            [buffers addObject:rawDataObj];
        }
        
        //unlock pixel buffer data
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
        dispatch_async(_video_queue, ^{
            // Wait until AVAssetWriterInput is ready
            while(!_videoWriterInput.readyForMoreMediaData)
                usleep(1000);
            
            // Lock from other threads
            [_pixelBufferLock lock];
            // Add the new frame to the video
            [_pixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:frameTime];
            
            // Unlock
            //CVPixelBufferRelease(pixelBuffer);
            [_pixelBufferLock unlock];
        });
    });
}

#pragma mark - Encoding
- (void)setupVideoContext
{
    // Get the screen rect and scale
    CGRect screenRect = [UIScreen mainScreen].bounds;
    float scale = [UIScreen mainScreen].scale;
    
    // setup the width and height of the framebuffer for the device
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // iPhone frame buffer is Portrait
        _width = screenRect.size.width * scale;
        _height = screenRect.size.height * scale;
    } else {
        // iPad frame buffer is Landscape
        _width = screenRect.size.height * scale;
        _height = screenRect.size.width * scale;
    }
    
    // Get the output file path
    NSString *outPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.mp4"];
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"record"] boolValue]){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM:dd:yyyy h:mm:ss a"];
        NSString *date = [dateFormatter stringFromDate:[NSDate date]];
        NSString *outName = [NSString stringWithFormat:@"Documents/%@.mp4",date];
        outPath = [NSHomeDirectory() stringByAppendingPathComponent:outName];
        [dateFormatter release];
    }
    
    NSError *error = nil;
    
    // Setup AVAssetWriter with the output path
    _videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:outPath]
                                             fileType:AVFileTypeMPEG4
                                                error:&error];
    // check for errors
    if(error)
    {
        NSLog(@"error: %@", error);
        return;
    }
    
    // Makes sure AVAssetWriter is valid (check check check)
    NSParameterAssert(_videoWriter);
    
    // Setup AverageBitRate, FrameInterval, and ProfileLevel (Compression Properties)
    NSMutableDictionary * compressionProperties = [NSMutableDictionary dictionary];
    [compressionProperties setObject: [NSNumber numberWithInt: _kbps * 1000] forKey: AVVideoAverageBitRateKey];
    [compressionProperties setObject: [NSNumber numberWithInt: _fps] forKey: AVVideoMaxKeyFrameIntervalKey];
    [compressionProperties setObject: AVVideoProfileLevelH264Main41 forKey: AVVideoProfileLevelKey];
    
    // Setup output settings, Codec, Width, Height, Compression
    int videowidth = _width;
    int videoheight = _height;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"vidsize"]) {
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"vidsize"] boolValue]){
            videowidth /= 2; //If it's set to half-size, divide both by 2.
            videoheight /= 2;
        }
    }
    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           AVVideoCodecH264, AVVideoCodecKey,
                                           [NSNumber numberWithInt:videowidth], AVVideoWidthKey,
                                           [NSNumber numberWithInt:videoheight], AVVideoHeightKey,
                                           compressionProperties, AVVideoCompressionPropertiesKey,
                                           nil];
    
    NSParameterAssert([_videoWriter canApplyOutputSettings:outputSettings forMediaType:AVMediaTypeVideo]);
    
    // Get a AVAssetWriterInput
    // Add the output settings
    _videoWriterInput = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                            outputSettings:outputSettings] retain];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"vidorientation"]) {
        float radians = [[[NSUserDefaults standardUserDefaults] objectForKey:@"vidorientation"] floatValue];
        _videoWriterInput.transform = CGAffineTransformMakeRotation(radians);
    }
    // Check if AVAssetWriter will take an AVAssetWriterInput
    NSParameterAssert(_videoWriterInput);
    NSParameterAssert([_videoWriter canAddInput:_videoWriterInput]);
    [_videoWriter addInput:_videoWriterInput];
    
    // Setup buffer attributes, PixelFormatType, PixelBufferWidth, PixelBufferHeight, PixelBufferMemoryAlocator
    NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                      [NSNumber numberWithInt:_width], kCVPixelBufferWidthKey,
                                      [NSNumber numberWithInt:_height], kCVPixelBufferHeightKey,
                                      kCFAllocatorDefault, kCVPixelBufferMemoryAllocatorKey,
                                      nil];
    
    // Get AVAssetWriterInputPixelBufferAdaptor with the buffer attributes
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
    // Tell the AVAssetWriterInput were done appending buffers
    [_videoWriterInput markAsFinished];
    
    // Tell the AVAssetWriter to finish and close the file
    [_videoWriter finishWriting];
    
    // Make objects go away
    [_videoWriter release];
    [_videoWriterInput release];
    [_pixelBufferAdaptor release];
    _videoWriter = nil;
    _videoWriterInput = nil;
    _pixelBufferAdaptor = nil;
}


@end
