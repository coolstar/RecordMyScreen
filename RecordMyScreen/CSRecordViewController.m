//
//  CSRecordViewController.m
//  RecordMyScreen
//
//  Created by @coolstarorg on 12/29/12.
//  Copyright (c) 2012 CoolStar Organization. All rights reserved.
//

#import "CSRecordViewController.h"
#import <IOMobileFrameBuffer.h>
#import <IOSurface.h>

extern UIImage *_UICreateScreenUIImage();

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

- (void)record:(id)sender {
    _statusLabel.text = @"00:00:00";
    _recordStartDate = [[NSDate date] retain];
    _stop.enabled = YES;
    _record.enabled = NO;
    
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
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        CGSize size = [UIScreen mainScreen].bounds.size;
        [self encodeVideotoPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.mp4"] size:size];
    });
    continuerecording = YES;
}

- (void)stop:(id)sender {
    _stop.enabled = NO;
    
    [_recordingTimer invalidate];
    _recordingTimer = nil;
    
    _statusLabel.text = @"Waiting for encoder to finish...";
    _progressView.hidden = NO;

    [_audioRecorder stop];
    [_audioRecorder release];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        continuerecording = NO;
        isdone = NO;
        while (!isdone){
            //wait until it's done
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _statusLabel.text = @"Ready";
            _progressView.hidden = YES;
            _record.enabled = YES;
            [_recordStartDate release];
            _recordStartDate = nil;
            _audioRecorder = nil;
        });
    });
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

- (CGImageRef) grabShot {
    //UIImage *shot = _UICreateScreenUIImage();
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; //This is a loop. We need our own Pool!
    
    IOMobileFramebufferConnection connect;
    kern_return_t result;
    CoreSurfaceBufferRef screenSurface = NULL;
    
    io_service_t framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleH1CLCD"));
    if(!framebufferService)
        framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleM2CLCD"));
    if(!framebufferService)
        framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleCLCD"));
    
    result = IOMobileFramebufferOpen(framebufferService, mach_task_self(), 0, &connect);
    
    result = IOMobileFramebufferGetLayerDefaultSurface(connect, 0, &screenSurface);
    
    uint32_t aseed;
    IOSurfaceLock(screenSurface, kIOSurfaceLockReadOnly, &aseed);
    uint32_t width = IOSurfaceGetWidth(screenSurface);
    uint32_t height = IOSurfaceGetHeight(screenSurface);
    
    CFMutableDictionaryRef dict;
    int pitch = width*4, size = 4*width*height;
    int bPE=4;
    char pixelFormat[4] = {'A','R','G','B'};
    CFNumberRef surfaceBytesPerRow,surfaceBytesPerElement,surfaceWidth,surfaceHeight,surfacePixelFormat,surfaceAllocSize; //these will be released soon
    
    dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(dict, kIOSurfaceIsGlobal, kCFBooleanTrue);
    
    surfaceBytesPerRow = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &pitch);
    CFDictionarySetValue(dict, kIOSurfaceBytesPerRow, surfaceBytesPerRow);
    
    surfaceBytesPerElement = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bPE);
    CFDictionarySetValue(dict, kIOSurfaceBytesPerElement, surfaceBytesPerElement);
    
    surfaceWidth = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &width);
    CFDictionarySetValue(dict, kIOSurfaceWidth, surfaceWidth);
    
    surfaceHeight = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &height);
    CFDictionarySetValue(dict, kIOSurfaceHeight, surfaceHeight);
    
    surfacePixelFormat = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, pixelFormat);
    CFDictionarySetValue(dict, kIOSurfacePixelFormat, surfacePixelFormat);
    
    surfaceAllocSize = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &size);
    CFDictionarySetValue(dict, kIOSurfaceAllocSize, surfaceAllocSize);
    
    IOSurfaceRef destSurf = IOSurfaceCreate(dict);
    CoreSurfaceAcceleratorRef outAcc;
    CoreSurfaceAcceleratorCreate(NULL, 0, &outAcc);
    
    CFDictionaryRef ed = (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys: nil];
    CoreSurfaceAcceleratorTransferSurfaceWithSwap(outAcc, screenSurface, destSurf, ed);
    
    IOSurfaceUnlock(screenSurface, kIOSurfaceLockReadOnly, &aseed); //stop locking these things! seriously!
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, IOSurfaceGetBaseAddress(destSurf), (width*height*4), NULL);
    CGColorSpaceRef devicergb = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width, height, 8, 8*4, IOSurfaceGetBytesPerRow(destSurf), devicergb, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little, provider, NULL, YES, kCGRenderingIntentDefault);

    CGColorSpaceRelease(devicergb);
    CGDataProviderRelease(provider);
    
    CFRelease(outAcc);
    
    CFRelease(surfaceBytesPerRow); //Don't keep these in the RAM. They're poisonous!
    CFRelease(surfaceBytesPerElement);
    CFRelease(surfaceWidth);
    CFRelease(surfaceHeight);
    CFRelease(surfacePixelFormat);
    CFRelease(surfaceAllocSize);
    CFRelease(dict);
    
    IOServiceClose(framebufferService); //Close those connections!
    IOServiceClose(connect);
    
    [pool drain]; //PURGE THE AUTORELEASED STUFF NAO!
    CFRelease(destSurf);
    return cgImage;
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
    [super dealloc];
}

-(void)encodeVideotoPath:(NSString*)path size:(CGSize)size
{
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
                                                           fileType:AVFileTypeMPEG4
                                                              error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithFloat:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithFloat:size.height], AVVideoHeightKey,
                                   nil];
    AVAssetWriterInput* writerInput = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                          outputSettings:videoSettings] retain];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                                                                                     sourcePixelBufferAttributes:nil];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    
    
    //Start a session:
    [writerInput setExpectsMediaDataInRealTime:YES];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    int i = 0;
    CGImageRef templateImage = [self grabShot];
    buffer = [self pixelBufferFromCGImage:templateImage size:size];
    CVPixelBufferPoolCreatePixelBuffer (NULL, adaptor.pixelBufferPool, &buffer);
    
    //[adaptor appendPixelBuffer:buffer withPresentationTime:kCMTimeZero];
    while (writerInput.readyForMoreMediaData && continuerecording)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; //Some devices just don't have enough RAM to wait for the global pool (I'm looking at you iPhone 3GS, iPod touch 3G, and iPod touch 4)
        CMTime frameTime = CMTimeMake(1, 1);
        CMTime lastTime=CMTimeMake(i, 6);
        CMTime presentTime=CMTimeAdd(lastTime, frameTime);
        
        CGImageRef image = [self grabShot];
        buffer = [self pixelBufferFromCGImage:image size:size];
        
        [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
        CVPixelBufferRelease(buffer);
        CGImageRelease(image);
        [pool drain]; //Yo dawg, I heard you liked pools, but unfortunately this one needs to be drained.
        usleep(1.0*1000.0/30); //30 Frames Per Second
        i++;
    }
    [writerInput markAsFinished];
    [videoWriter finishWriting];
    
    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
    CGImageRelease(templateImage);
    [videoWriter release];
    [writerInput release];
    isdone = YES;
}

- (CVPixelBufferRef) pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width,
                                          size.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    //CGContextTranslateCTM(context, 0, CGImageGetHeight(image));
    //CGContextScaleCTM(context, 1.0, -1.0);//Flip vertically to account for different origin
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

@end
