
#import "VideoManager.h"
#import "UIExtras.h"
#import "ScreenView.h"
#import "OrienteDevice.h"
#import <CoreVideo/CoreVideo.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <unistd.h>
#import <AVFoundation/AVCaptureSession.h>
#import <AudioToolbox/AudioToolbox.h>
#import "OsGetTime.h"
#import "SkyMain.h"
#import "SkyTr3Root.h"

// KVO contexts
static void *KVOTorchMode = &KVOTorchMode;
static void *KVOAdjusting = &KVOAdjusting;

@implementation VideoManager

#define PrintVideoManager(...)//DebugPrint(__VA_ARGS__)
#define LogVideoManager(...) DebugLog(__VA_ARGS__)
#define AudioSupport 1

@dynamic resolutionPreset;
@dynamic torchLevel;

+ (id) shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [self.alloc init];
    });
    return shared;
}

- (id)init {
    
    _videoCaptureQueue = dispatch_queue_create("ChromaKey.capture", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(_videoCaptureQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    _videoProcessingQueue = dispatch_queue_create("ChromaKey.processing", DISPATCH_QUEUE_SERIAL);
    _lastAudioCMTime = kCMTimeZero;
    
    _active     = NO;
    _ciContext  = nil;
    _torchLevel = 0;
    _writing    = NO;
    
    _previousSecondTimes = [NSMutableArray.alloc init];
    _captureSession = [AVCaptureSession.alloc init];

#ifdef Use1080p
    _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    _videoDimensions.width  = 1920;
    _videoDimensions.height = 1080;
#else
    _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    _videoDimensions.width  = 1280;
    _videoDimensions.height = 720;
#endif
    _captureFlags = kDeviceCaptureNone;
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];	
    
    _captureSessionObserver = [[NSNotificationCenter defaultCenter] addObserverForName:nil object:_captureSession queue:nil usingBlock:^(NSNotification *n) {
        if ( [[n name] isEqualToString:AVCaptureSessionRuntimeErrorNotification] ) 
            LogVideoManager(@"Capture runtime error: %@", [(NSError*)[[n userInfo] objectForKey:AVCaptureSessionErrorKey] localizedDescription]);
        else if ( [[n name] isEqualToString:AVCaptureSessionDidStartRunningNotification] )
            LogVideoManager(@"Capture did start running.");
        else if ( [[n name] isEqualToString:AVCaptureSessionDidStopRunningNotification] )
            LogVideoManager(@"Capture did stop running.");
        else if ( [[n name] isEqualToString:AVCaptureSessionWasInterruptedNotification] )
            LogVideoManager(@"Capture was interrupted.");
        else if ( [[n name] isEqualToString:AVCaptureSessionInterruptionEndedNotification] )
            LogVideoManager(@"Capture interruption ended.");
    }];
    
    [self addObserver:self forKeyPath:@"videoDevice.torchMode"              options:NSKeyValueObservingOptionNew context:KVOTorchMode];
    [self addObserver:self forKeyPath:@"videoDevice.adjustingExposure"      options:NSKeyValueObservingOptionNew context:KVOAdjusting];
    [self addObserver:self forKeyPath:@"videoDevice.adjustingWhiteBalance"  options:NSKeyValueObservingOptionNew context:KVOAdjusting];
    
    self.adjusting = (self.videoDevice.adjustingExposure ||
                      self.videoDevice.adjustingWhiteBalance);
    self.writing   = NO;
    self.importing = NO;
    self.optimize  = YES;
    self.active    = YES;
    
    return self;
}

- (void)setSnapshotDelegate:(id)snapshotDelegate {
        
    _snapshotDelegate = snapshotDelegate;
    
    if (snapshotDelegate) {
    
        [self startWritingVideo];
    }
}

- (id)snapshotDelegate {

    return _snapshotDelegate;
}

- (void)setCaptureFlags:(DeviceCaptureFlags)captureFlags {
    
    [_captureSession stopRunning];
    
    NSArray *inputs = [_captureSession inputs];
    for (AVCaptureInput *input in inputs) {
        [_captureSession removeInput:input];
    }
    [self addAudioVideoInput:captureFlags];
    
    [_captureSession startRunning];
}

- (void)setActive:(bool)active_ {
    
    _active = active_;

    if (_captureFlags & kDeviceCaptureCameraBack  ||
        _captureFlags & kDeviceCaptureCameraFront) {    
        
        if (_active) {
            //fprintf(stderr, "(start)");
            [_captureSession startRunning];
        }
        else {
            //fprintf(stderr, "(stop)");
            [_captureSession  stopRunning];
        }
    }
}
- (bool)isActive {
    
    return _active;
}

#pragma mark - Pixelbuffer Processing

- (void)appendToAssetWriterInput:(CMSampleBufferRef)sampleBuffer pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
}

#pragma mark - Device settings

-(NSString*) resolutionPreset {
	return _captureSession.sessionPreset;
}

- (void)setResolutionPreset:(NSString*)newValue {	
    
    if (_captureSession.sessionPreset != newValue) {
	
        if (![_captureSession canSetSessionPreset:newValue]) {
            LogVideoManager(@"Couldn't change capture preset");
        }
        else {
			_captureSession.sessionPreset = newValue;
		}
    }
}

-(AVCaptureTorchMode) torchMode {
    return [self.videoDevice torchMode];
}

- (void)setTorchLevel:(CGFloat)level_ {    
    
    AVCaptureDevice *device = self.videoDevice;
    NSError *error;
    
    if (level_ <.01) {
        
        if (_torchLevel > 0 &&  
            [device isTorchModeSupported:AVCaptureTorchModeOff] && 
            [device torchMode] != AVCaptureTorchModeOff &&
            [device lockForConfiguration:&error]) {
            
            [device setTorchMode:AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
        _torchLevel = 0;
    }
    else {
        
        
        if ([device isTorchModeSupported:AVCaptureTorchModeOn]  &&
            [device lockForConfiguration:&error] ) {
            
            if (_torchLevel == 0 && [device torchMode] != AVCaptureTorchModeOn)
                device.torchMode = AVCaptureTorchModeOn;
#define AllowTorchLevelToBeReadwrite 0
#if AllowTorchLevelToBeReadwrite
            device.torchLevel=level_;
#endif
            [device unlockForConfiguration];
        }
        _torchLevel = level_;
    }
}


- (void)unlockWhiteAndExposureBalanceAtPoint:(CGPoint)point {  
    
    NSError *error;
    if ([self.videoDevice lockForConfiguration:&error]) {
        
        if ([self.videoDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [self.videoDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        if ([self.videoDevice isExposurePointOfInterestSupported]) {
            [self.videoDevice setExposurePointOfInterest:point];
        }            
        if ([self.videoDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.videoDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [self.videoDevice unlockForConfiguration];
    }
}

- (void)lockWhiteAndExposureBalanceAtPoint:(CGPoint)point {
    
    NSError *error;
    if ([self.videoDevice lockForConfiguration:&error]) {
        
        if ([self.videoDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {
            [self.videoDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
        }
        if ([self.videoDevice isExposurePointOfInterestSupported]) {
            [self.videoDevice setExposurePointOfInterest:point];
        }            
        if ([self.videoDevice isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [self.videoDevice setExposureMode:AVCaptureExposureModeLocked];
        }
        [self.videoDevice unlockForConfiguration];
    }
}

- (void)calculateFramerateForSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    CMTime timeVal = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
	[_previousSecondTimes addObject:[NSValue valueWithCMTime:timeVal]];
	CMTime oneSecond = CMTimeMake(1,1);
	CMTime oneSecondAgo = CMTimeSubtract(timeVal, oneSecond);
    NSValue *lastValue = nil;
	while((lastValue = [_previousSecondTimes objectAtIndex:0]) && 
          (CMTIME_COMPARE_INLINE([lastValue CMTimeValue], <, oneSecondAgo))) {
		[_previousSecondTimes removeObjectAtIndex:0]; 
    }
	float newVideoFrameRate = (self.videoFrameRate + [_previousSecondTimes count])/2.;
	
    self.videoFrameRate = newVideoFrameRate;
    Debug (
           static int count = 0;
           count ++;
           if (count%60==0) {
               LogVideoManager(@"Framerate:%.1f", self.videoFrameRate);
           }
    )
}

- (void)removeFileURL:(NSURL*)fileURL {
        
    LogVideoManager(@"%s fileURL %@", sel_getName(_cmd),fileURL);
    NSString *outputPath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:outputPath]) {
        [fileManager removeItemAtPath:outputPath error:nil];
        LogVideoManager(@"%s fileURL %@", sel_getName(_cmd),fileURL);
    }
}

#pragma mark - Capture Delegate


- (void)testVideoDiminsionsForSampleBuffer:(CMSampleBufferRef)sampleBuffer  {
    
    CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);	
    CMVideoDimensions videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDesc);
    CMVideoCodecType videoType = CMFormatDescriptionGetMediaSubType(formatDesc);
    
    if (videoDimensions.width   != _videoDimensions.width ||
        videoDimensions.height  != _videoDimensions.height ||
        videoType               != _videoType) {
        
        _videoDimensions = videoDimensions;
        _videoType = videoType;
        [self cancelWriting];
    }
}


- (void)renderSample:(CMSampleBufferRef)sampleBuffer mirror:(bool)mirror {
    
    ScreenView *screenView = [ScreenView shared];
    
    if (!self.writing) {
        
        PrintVideoManager("☐");
        [screenView renderMirror:mirror];
    }
    else {
        
        [screenView renderMirror:mirror
                 completionBlock:^(CVImageBufferRef imageBuffer, NSError *error) {
                     
                     if (error) {
                         LogVideoManager(@"%s error %@",sel_getName(_cmd), error);
                         [self cancelWriting];
                         _snapshotDelegate = nil;
                     }
                     else if (self.snapshotDelegate) {
                         
                         [self cancelWriting];
                         
                         [_snapshotDelegate performSelectorOnMainThread:@selector(snapshotDelegateImage:)
                                                             withObject:[self snapshotImageBuffer:imageBuffer]
                                                          waitUntilDone:NO];
                         _snapshotDelegate = nil;
                         
                     }
                     else {
                         
                         dispatch_sync(_videoProcessingQueue, ^{
                             
                             [self assetWriterAppendSampleBuffer:sampleBuffer
                                                     imageBuffer:imageBuffer];
                         });
                     }
                 }
         ];
    }
}

#pragma mark - new audio video samples

- (void)captureOutput:(AVCaptureOutput*)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection*)connection {
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        if (![_captureSession isRunning])
            return;
        
        
        if (captureOutput == _audioOutput) {
            
            if (!self.isWriting)
                return;
            
            if(_assetWriter.status > AVAssetWriterStatusWriting) {
                
                LogVideoManager(@"Warning: writer status is %ld", (long)_assetWriter.status);
                if( _assetWriter.status == AVAssetWriterStatusFailed )
                    LogVideoManager(@"Error: %@", _assetWriter.error);
                return;
            }
            if (!_audioWriterInput.readyForMoreMediaData) {
                PrintVideoManager("!");
            }
            else {
                _lastAudioCMTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                if (![_audioWriterInput appendSampleBuffer:sampleBuffer]) {
                    LogVideoManager(@"Unable to write to audio input");
                }
            }
            
        }
        else if (captureOutput == _videoOutput) {
            
            [self calculateFramerateForSampleBuffer:sampleBuffer];
            [self testVideoDiminsionsForSampleBuffer:sampleBuffer];
            bool mirror = (_captureFlags & kDeviceCaptureCameraFront);
            
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            [ScreenView.shared setCamBuf:imageBuffer camPal:nil];
            [self renderSample:sampleBuffer mirror:mirror];
            [SkyMain.shared getNextFrame];
        }
    });
}


#pragma mark - capture session configuration

- (bool)hasVideoDeviceForPosition:(AVCaptureDevicePosition)devicePosition {
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices) {        
        if (device.position == devicePosition) {
            return true;
        }
    } 
    return false;
}
-(AVCaptureDevice*)videoDeviceForPosition:(AVCaptureDevicePosition)devicePosition {
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices) {        
        if (device.position == devicePosition) {
            _captureFlags = (DeviceCaptureFlags) devicePosition;
            return device;
        }
    } 
    return nil;
}

-(AVCaptureDevice*)anyVideoDeviceForPosition:(AVCaptureDevicePosition)devicePosition {
    
    AVCaptureDevice *device = [self videoDeviceForPosition:devicePosition];
    if (device)
        return device;
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _captureFlags = (device ? kDeviceCaptureCameraBack : kDeviceCaptureNone);
    return device;
}

- (bool)addAudioVideoInput:(DeviceCaptureFlags)captureFlags {
    
    NSError *error;
    AVCaptureDevice *videoDevice;
    AVCaptureDeviceInput *videoIn;
    AVCaptureDevice *audioDevice;
    AVCaptureDeviceInput *audioIn;
    UInt32 sessionCategory;
    
    //audio OSStatus propertySetError = 0;    
    //audio UInt32 allowMixing = true;
    
    // Video Input ------------------
    
    if (captureFlags & kDeviceCaptureCameraFront || 
        captureFlags & kDeviceCaptureCameraBack) {
        
        if (!(videoDevice = [self anyVideoDeviceForPosition:(AVCaptureDevicePosition)captureFlags])) {
            LogVideoManager(@"%s Couldn't create VIDEO capture device",sel_getName(_cmd));
            goto bail;
        }
        if (!(videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error]) || error) {
            LogVideoManager(@"%s Couldn't create VIDEO input",sel_getName(_cmd));
            goto bail;
        }
        if (![_captureSession canAddInput:videoIn]) {
            LogVideoManager(@"%s Couldn't add VIDEO input",sel_getName(_cmd));
            goto bail;
        }
        [_captureSession addInput:videoIn];
        self.videoDevice = [videoIn device];
    }
    // Audio Input ------------------
    
    sessionCategory = kAudioSessionCategory_PlayAndRecord;    
    
    AudioSessionSetProperty ( kAudioSessionProperty_AudioCategory,                       
                             sizeof (sessionCategory),                                   
                             &sessionCategory);
    
    if (!(audioDevice=[AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeAudio])) {
        LogVideoManager(@"%s Couldn't create AUDIO device",sel_getName(_cmd));
        goto bail;
    }
    if (!(audioIn = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error ]) || error) {
        LogVideoManager(@"%s Couldn't create AUDIO input",sel_getName(_cmd));
        goto bail;
    }
    if (![_captureSession canAddInput:audioIn]) {
        LogVideoManager(@"%s Couldn't add AUDIO input",sel_getName(_cmd));
        goto bail;
    }
    [_captureSession addInput:audioIn];
    return YES;
    
bail:
    [self setActive:NO];
    return NO;
}

- (bool)addAudioDataOutput {
    
    if (_audioOutput) 
        return YES;
    
    _audioOutput = [AVCaptureAudioDataOutput.alloc init];
    
    if (![_captureSession canAddOutput:_audioOutput]) {
        LogVideoManager(@"%s Couldn't add AUDIO output",sel_getName(_cmd));
        goto bail;
    }
    [_captureSession addOutput:_audioOutput];
    [_audioOutput setSampleBufferDelegate:self queue:_videoCaptureQueue]; 
    return YES;
bail:
    ; _audioOutput = 0;  
    return NO;
}

- (bool) addVideoDataOutput {
    
    // Video output ------------------
	_videoOutput = [AVCaptureVideoDataOutput.alloc init];
    _videoOutput.alwaysDiscardsLateVideoFrames=YES;
        
    //NSDictionary *formatYUV = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    NSDictionary *formatBGRA = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [_videoOutput setVideoSettings:formatBGRA];
    {
        if (![_captureSession canAddOutput:_videoOutput]) {
            LogVideoManager(@"%s Couldn't add VIDEO output",sel_getName(_cmd));
            goto bail;
        }
        [_captureSession addOutput:_videoOutput];
                
        // Video output ------------------
        [_videoOutput setSampleBufferDelegate:self queue:_videoCaptureQueue];
        
        return YES;
    }
bail:
    ; _videoOutput = 0;   
    return NO;
}

#pragma mark -


- (void) startCamera:(DeviceCaptureFlags)captureFlags_ {

    _captureFlags = captureFlags_;
    
    if (_captureFlags & kDeviceCaptureCameraFront ||
        _captureFlags & kDeviceCaptureCameraBack) {
    
            [self addVideoDataOutput];
            [self addAudioDataOutput];
            [self stopWritingVideo];
        }
}

#pragma mark - Capture Session

-(CGAffineTransform)transformForDeviceOrientation {

    UIDeviceOrientation orientation =[UIScreen currentDeviceOrientation];
    
  	switch (orientation) {
        
        case UIDeviceOrientationPortrait:           return CGAffineTransformMakeRotation(1*M_PI_2);
        case UIDeviceOrientationLandscapeRight:     return CGAffineTransformMakeRotation(2*M_PI_2);
        case UIDeviceOrientationPortraitUpsideDown: return CGAffineTransformMakeRotation(3*M_PI_2);
        default:                                    return CGAffineTransformIdentity;
    }
}

- (BOOL)createAssetWriter {
    
    NSURL *fileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"VenusPearl.mov"] isDirectory:NO];
    [self removeFileURL:fileURL];
    LogVideoManager(@"%s fileURL %@", sel_getName(_cmd),fileURL);

    NSError *error = nil;
	if (!(_assetWriter = [AVAssetWriter.alloc initWithURL:fileURL fileType:(NSString*)kUTTypeQuickTimeMovie error:&error])||error) {
		LogVideoManager(@"Couldn't create AVAssetWriter (%@ %@)", error, [error userInfo]);
        return NO;
    }    
    [ScreenView.shared initRenderWithDimensions:_videoDimensions];
    CMVideoDimensions dimensions = _videoDimensions;
	{    
        int bitsPerSecond = 2625000 * 8 * 2;
#if 1
        if      (dimensions.width <= 192) bitsPerSecond =   16000 * 8;
        else if (dimensions.width <= 480) bitsPerSecond =   87500 * 8;
        else if (dimensions.width <= 640) bitsPerSecond =  437500 * 8;
        else if (dimensions.width <= 640) bitsPerSecond = 1312500 * 8;
        else /* 1280p */                  bitsPerSecond = 2625000 * 8;
#endif
        NSDictionary *compression =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithInteger:bitsPerSecond],AVVideoAverageBitRateKey,
         [NSNumber numberWithInteger:1], AVVideoMaxKeyFrameIntervalKey, // set to 1 to make every frame a key frame
         nil];
        
        NSDictionary *videoSettings = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         AVVideoCodecH264,                          AVVideoCodecKey,
         [NSNumber numberWithInt:dimensions.width], AVVideoWidthKey,
         [NSNumber numberWithInt:dimensions.height],AVVideoHeightKey,
         compression,                               AVVideoCompressionPropertiesKey, nil];
        
        if (![_assetWriter canApplyOutputSettings:videoSettings forMediaType:AVMediaTypeVideo]) {
            LogVideoManager(@"Couldn't apply video output settings.");
            goto bail;
        }
        _videoWriterInput = [AVAssetWriterInput.alloc initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        _videoWriterInput.expectsMediaDataInRealTime = NO;
        _videoWriterInput.transform = [self transformForDeviceOrientation];
        
        // adapter ---------------------------------------------------
        
        NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                               [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], 
                                                               kCVPixelBufferPixelFormatTypeKey, nil];
        
        _pixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoWriterInput
                               sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
        
        // adapter end -----------------------------------------------
        
        if (![_assetWriter canAddInput:_videoWriterInput]) {
            LogVideoManager(@"Couldn't add asset writer VIDEO input.");
            goto bail;
        }
        [_assetWriter addInput:_videoWriterInput];
        
        // Add the Audio input -------------------------------------------
        
        AudioChannelLayout acl = {0};
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
        
        NSDictionary* audioOutputSettings = nil;          
        // Both type of audio inputs causes output video file to be corrupted.
        audioOutputSettings = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
         [ NSNumber numberWithInt:                    1], AVNumberOfChannelsKey,
         [ NSNumber numberWithFloat:              44100], AVSampleRateKey,
         [ NSNumber numberWithInt:                64000], AVEncoderBitRatePerChannelKey,
         [ NSData dataWithBytes:&acl length:sizeof(acl)], AVChannelLayoutKey,
         nil];
        
        _audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio 
                                                                outputSettings:audioOutputSettings ];
        
        _audioWriterInput.expectsMediaDataInRealTime = YES;
        
        if (![_assetWriter canAddInput:_audioWriterInput]) {
            LogVideoManager(@"Couldn't add asset writer AUDIO input.");
            goto bail;
        }
        [_assetWriter addInput:_audioWriterInput];
    }    
    return YES;
bail:
    ; _assetWriter = 0;
     _videoWriterInput = 0; 
     _audioWriterInput = 0; 
    
    return NO;
}

UIImage* orientedImage(UIImage* src) {
    
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context(UIGraphicsGetCurrentContext());
    
    [src drawAtPoint:CGPointMake(0, 0)];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

-(UIImage*) snapshotImageBuffer:(CVImageBufferRef)imageBuffer {
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context); 
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context); 
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage.alloc initWithCGImage:quartzImage];
    UIInterfaceOrientation orientation = [OrienteDevice shared].interface;
    bool mirror =  (_captureFlags & kDeviceCaptureCameraFront);
    
    UIImage *rotatedImage = rotate(image,orientation,mirror);    
    return rotatedImage;

}
CFTimeInterval thisTime = CFAbsoluteTimeGetCurrent();


- (bool)assetWriterGoWrite {
    
    static int64_t frame = 0;
    
    if (!_writingDidSart) {
        
        BOOL success = [_assetWriter startWriting];
        if (!success) {
            LogVideoManager(@"%s startWriting failed",sel_getName(_cmd));
            return NO;
        }
        [_assetWriter startSessionAtSourceTime:CMTimeSinceStartup()];
        frame = 0;
        _writingDidSart = YES;
    }
    return YES;
}

// was appendVideoToAssetWriterInput
- (BOOL)assetWriterAppendSampleBuffer:(CMSampleBufferRef)sampleBuffer
                          imageBuffer:(CVImageBufferRef)imageBuffer {
    
    if (!imageBuffer && !sampleBuffer)
        return NO;
    
    if (![self assetWriterGoWrite]) {
        return NO;
    }
    if (!_videoWriterInput.readyForMoreMediaData) {

        LogVideoManager(@"%s !readyForMoreMediaData",sel_getName(_cmd));
        return YES; // Not ready but that's ok
    }
    if (!sampleBuffer) {
        
        CMTime thisTime = CMTimeSinceStartup();
        return [_pixelBufferAdaptor appendPixelBuffer:imageBuffer
                                 withPresentationTime:thisTime];
    }
    else {
        CMSampleBufferRef resultBuffer = NULL;
        CMFormatDescriptionRef formatDescription = NULL;

        CMSampleTimingInfo	timingInfo = kCMTimingInfoInvalid;
        BOOL success = NO;
        OSStatus err =  noErr;
#define GoErr(A,B,C) err = A B; if (err) { LogVideoManager(@"%s::%s err: %i",sel_getName(_cmd),(char*)#A, (int)err); C;  }

        GoErr(CMVideoFormatDescriptionCreateForImageBuffer, (kCFAllocatorDefault, imageBuffer, &formatDescription),goto bail)
        GoErr(CMSampleBufferGetSampleTimingInfo,(sampleBuffer, 0, &timingInfo),goto bail)
        GoErr(CMSampleBufferCreateForImageBuffer, (kCFAllocatorDefault, imageBuffer, TRUE, NULL, NULL,  formatDescription, &timingInfo, &resultBuffer),goto bail)
        CMPropagateAttachments(sampleBuffer, resultBuffer);
        
        success = [_videoWriterInput appendSampleBuffer:resultBuffer];
        
    bail:
        if (resultBuffer) {
            CFRelease(resultBuffer);
        }
        if (formatDescription) {
            CFRelease(formatDescription);
        }
        return success;
    }
}

- (void)startRunning {
    
    if ([_captureSession isRunning] == NO) {
        [_captureSession startRunning];
    }  
}

- (void)startWritingVideo {
    
    dispatch_sync(_videoProcessingQueue, ^{    
    
        if (!self.importing && !self.writing) {
        
            self.writing = [self createAssetWriter];
            _writingDidSart = NO;
        }
    });
}

- (void)stopWritingVideo {
    
    dispatch_sync(_videoProcessingQueue, ^{
    
        if (self.writing) {   
        
           _fileURL = [_assetWriter outputURL];
            
            BOOL success = [_assetWriter finishWriting];
            LogVideoManager(@"finishWriting:%d FileURL:%@", success,_fileURL);
            
            if (success) {
            
                ALAssetsLibrary *library = [ALAssetsLibrary.alloc init];
                
                if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:_fileURL]) {
				
                    self.importing = YES;
                    [library writeVideoAtPathToSavedPhotosAlbum:_fileURL
                                                completionBlock:^(NSURL *assetURL, NSError *error){
                                                    if (error)  { LogVideoManager(@"Error: %@ %@", error, [error userInfo]); }
                                                    else        { LogVideoManager(@"Video save: %@", assetURL); }
													self.importing = NO;													 
                                                }];
                }
            }
            else {
                LogVideoManager(@"finishWriting failed");
            }   
            
             _assetWriter      = NULL;
             _videoWriterInput = NULL;  
             _audioWriterInput = NULL;   
			self.writing = NO;
        }	                
    });
}

- (void)cancelWriting {     
    
    dispatch_sync(_videoProcessingQueue, ^{
    
        if (self.writing) {             
        
            NSURL *fileURL = [_assetWriter outputURL];              
            [_assetWriter cancelWriting];
            
            [self removeFileURL:fileURL];
            
             _assetWriter      = NULL;
             _videoWriterInput = NULL;   
             _audioWriterInput = NULL;   
            
            self.writing = NO; 
        }
    });
}

- (void)dealloc {
    
    [self cancelWriting];
    [self removeObserver:self forKeyPath:@"videoDevice.torchMode"];
    [self removeObserver:self forKeyPath:@"videoDevice.adjustingExposure"];
    [self removeObserver:self forKeyPath:@"videoDevice.adjustingWhiteBalance"];
    
	[_captureSession stopRunning];
	[[NSNotificationCenter defaultCenter] removeObserver:_captureSessionObserver];
    
    if (_videoProcessingQueue) {
        _videoProcessingQueue = NULL;
    }
    if (_videoCaptureQueue) {
        _videoCaptureQueue = NULL;
    }
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    
    if ([[change objectForKey:NSKeyValueChangeNewKey] isEqual:[NSNull null]]) {
    
        return;
    }
    if (KVOTorchMode == context) {
        
        if ([[change objectForKey:NSKeyValueChangeNewKey] integerValue] != [self torchMode]) {
        
            //[self setTorchMode:[[change objectForKey:NSKeyValueChangeNewKey] integerValue]];
        }
    } 
    else if (KVOAdjusting == context) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            self.adjusting = self.videoDevice.adjustingExposure || self.videoDevice.adjustingWhiteBalance;
        });
    }     
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
