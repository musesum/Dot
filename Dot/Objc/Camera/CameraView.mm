#import "CameraView.h"
#import "VideoManager.h"
#import "ThumbSwitch.h"
#import "ThumbFlip.h"
#import "SysSoundController.h"
#import "ScreenView.h"
#import "MenuDock+Reveal.h"
#import "MenuChild.h"
#import "AlertSound.h"
#import "UIExtras.h"
#import "TextLabel.h"
#import "VideoManager.h"
#import "InfoView.h"
#import "SkyDefs.h"

#define PrintCameraVC(...) //DebugPrint(__VA_ARGS__)
#define LogCameraVC(...) //DebugLog(__VA_ARGS__)

@implementation CameraView

CGRect frameForImage(UIImage*image) {

    return CGRectMake(0,0, image.size.width, image.size.height);    
}

- (id)initWithDelegate:(id)delegate_ captureFlags:(DeviceCaptureFlags)captureFlags  {
    
    if (!(self = [super init])) 
        return nil;
    
    _videoRecording = NO;
    _cameraMode = kCameraModeStill;
    _exposureMode = kExposureAuto;
     
    self.frame = UIScreen.mainScreen.fixedCoordinateSpace.bounds;
    // setting frame to zero will eliminate touch to set focus for camera
    self.frame = CGRectZero; //TODO: set this with each video or drawn dot
    self.userInteractionEnabled = YES;
    
    UIImage* cameraPosition = [UIImage imageNamed:@"CameraPosition.png"];
    
    _cameraCrossCircle = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"CameraCrossCircle128.png"]];
    _cameraCrossEye    = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"CameraCrossEye128.png"]];    
    _cameraCrossLock   = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"CameraCrossLock128.png"]];        
    _videoManager = [VideoManager shared];


    //TODO: make this interchangeable with video and draw dots
    
    if ((captureFlags & kDeviceCaptureCameraFront ||
         captureFlags & kDeviceCaptureCameraBack) &&
        [_videoManager hasVideoDeviceForPosition:AVCaptureDevicePositionFront]) {
         
        _cameraPositionRect = frameForImage(cameraPosition);
        _cameraPosition = [UIButton.alloc initWithFrame:_cameraPositionRect];
        [_cameraPosition setImage:cameraPosition forState:UIControlStateNormal];
        [_cameraPosition addTarget:self action:@selector(onCameraPosition) forControlEvents:UIControlEventTouchUpInside];
        _cameraPosition.showsTouchWhenHighlighted = YES;
        _cameraPosition.hidden = YES;
        _cameraPosition.alpha = 0;
        _cameraPositionCamera = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"CameraPositionCamera"]];
        _cameraPositionCamera.center = CGPointMake(_cameraPosition.center.x, _cameraPosition.center.y-2);
        [_cameraPosition addSubview:_cameraPositionCamera];
    }
    else {
        _cameraPosition = nil;
        _cameraPositionCamera = nil;
        _cameraPositionRect = CGRectZero;
    }

    // record button in bottom center
    
    UIImage* recordButton = [UIImage imageNamed:@"RecButton.png"];
    _recordButtonRect = frameForImage(recordButton);
    _recordButton = [UIButton.alloc initWithFrame:_recordButtonRect];
    [_recordButton setImage:recordButton forState:UIControlStateNormal];
    _recordButton.selected = NO;
    [_recordButton addTarget:self action:@selector(onCameraRecord) forControlEvents:UIControlEventTouchUpInside];
    _recordButton.showsTouchWhenHighlighted = YES;
    _recordButton.hidden = YES;
    _recordButton.alpha = 0;
    
    _recButtonVideoOff = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"RecButtonVideoOff.png"]];
    _recButtonVideoOn  = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"RecButtonVideoOn.png"]];
    _recButtonStill    = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"RecButtonStill.png"]];
    _recButtonVideoOff .center = _recordButton.center;
    _recButtonVideoOn  .center = _recordButton.center;
    _recButtonStill    .center = _recordButton.center;
    _countDownLabel     = TextLabelWith(CGRectMake(0, 0, 32, 32),12,Center,@"30");
    _countDownLabel.alpha = 0;

    [_recordButton addSubview:_recButtonVideoOff];
    [_recordButton addSubview:_recButtonVideoOn];
    [_recordButton addSubview:_recButtonStill];
    [_recordButton addSubview:_countDownLabel];
    
    // still video toggle in lower right corner
    
    UIImage* videoStill= [UIImage imageNamed:@"ToggleVideoStill.png"];
    _stillVideoRect = CGRectMake(0, 0, 72, 40);
    _stillVideo = [UIButton.alloc initWithFrame:_stillVideoRect];
    [_stillVideo setImage:videoStill forState:UIControlStateNormal];
    _stillVideo.selected = NO;
    [_stillVideo addTarget:self action:@selector(onStillVideo) forControlEvents:UIControlEventTouchUpInside];
    _stillVideo.showsTouchWhenHighlighted = YES;
    _stillVideo.hidden = YES;
    _stillVideo.alpha = 0;
     
    _toggleStill = [UIImageView.alloc initWithImage: [UIImage imageNamed:@"ToggleStill"]];
    _toggleVideo = [UIImageView.alloc initWithImage: [UIImage imageNamed:@"ToggleVideo"]];
    _toggleStill.frame = CGRectMake(17,2, 17,14);
    _toggleVideo.frame = CGRectMake(37,4, 19,12);
    _toggleStill.alpha = .8;
    _toggleVideo.alpha = .8;
    _toggleThumb = [UIImageView.alloc initWithImage: [UIImage imageNamed:@"ToggleThumb"]];
    _toggleThumbLeft = CGRectMake(17,24, 15,9);
    _toggleThumbRight= CGRectMake(40,24, 15,9);
    _toggleThumb.frame = _toggleThumbLeft;
    [_stillVideo addSubview:_toggleStill];
    [_stillVideo addSubview:_toggleVideo];
    [_stillVideo addSubview:_toggleThumb];

    // torch slider in upper left
    {
        
#define TorchSlider 1
#if TorchSlider
//        CGRect frame = CGRectMake(0,0,80,40);
//        
//        _torchSwitch = [ThumbSwitch.alloc initWithFrame:frame cover:frame tr3Path:"main.torchlevel" off:@"dot.menu.back.png" on:@"TorchThumb.png"  duration:0 completion:^(CGFloat value, CGFloat progress) {
//                            [self.videoManager setTorchLevel:value];
//                        }];
//        _torchSwitch.alpha = 0;
//        _torchButton = nil;
#else
        
        UIImage* torchButtonOff = [UIImage imageNamed:@"TorchButtonOff.png"];
        UIImage* torchButtonOn  = [UIImage imageNamed:@"TorchButtonOn.png"];
        _torchButtonRect = frameForImage(torchButtonOn);
        _torchButton = [UIButton.alloc initWithFrame:_torchButtonRect];
        [_torchButton setImage:torchButtonOff forState:UIControlStateNormal];
        [_torchButton setImage:torchButtonOn forState:UIControlStateSelected];
        _torchButton.selected = NO;
        [_torchButton addTarget:self action:@selector(onCameraTorch) forControlEvents:UIControlEventTouchUpInside];
        _torchButton.showsTouchWhenHighlighted = YES;
        _torchButton.hidden = YES;
        _torchButton.alpha = 0;
        _torchSwitch = nil;
        
#endif
    }
    
    NSNumber* num = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCameraModeKey"];
    self.cameraMode = num ? (CameraMode)[num integerValue] : kCameraModeStill;

    return self;
}

-(CGAffineTransform) transformForOrientation {
    
    UIDeviceOrientation orientation = [UIScreen currentDeviceOrientation];
    
    CGAffineTransform transform; // rotation
    
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown: transform = CGAffineTransformMakeRotation(2*M_PI_2); break;
        case UIDeviceOrientationLandscapeRight:     transform = CGAffineTransformMakeRotation(3*M_PI_2); break;
        case UIDeviceOrientationLandscapeLeft:      transform = CGAffineTransformMakeRotation(1*M_PI_2); break;
        case UIDeviceOrientationPortrait:           transform = CGAffineTransformMakeRotation(0*M_PI_2); break;
        default: break;
    }
    return transform;
}
- (void)arrangeButtons {
    
    CGSize screenSize = UIScreen.mainScreen.fixedCoordinateSpace.bounds.size;
    
    CGAffineTransform transform = [self transformForOrientation];
     
    // process portrait or landscape button frames and rotations
    
    [UIView animateWithDuration:.5 delay:0 options:AnimUserContinue
     
                     animations:^{ 
                         
                         _toggleStill.transform = transform;
                         _toggleVideo.transform = transform;
                         
                         _recButtonVideoOff .transform = transform;
                         _recButtonVideoOn  .transform = transform;
                         _recButtonStill    .transform = transform;
                         _countDownLabel    .transform = transform;

                         
                         _cameraPositionCamera.transform = transform;
                         ///!!! _torchSwitch.thumbFlip.transform = transform;
                         _torchButton.frame = CGRectMake(0,0, _torchButtonRect.size.width, _torchButtonRect.size.height);
                         
                         _stillVideo.frame = CGRectMake(screenSize.width -_stillVideoRect.size.width, 
                                                        screenSize.height-_stillVideoRect.size.height,
                                                        _stillVideoRect.size.width, 
                                                        _stillVideoRect.size.height);
                         
                         _cameraPosition.frame = CGRectMake(screenSize.width-_cameraPositionRect.size.width, 
                                                            0,
                                                            _cameraPositionRect.size.width, 
                                                            _cameraPositionRect.size.height);
                         
                         _recordButton.frame = CGRectMake(screenSize.width/2 -_recordButtonRect.size.width/2, 
                                                          screenSize.height-_recordButtonRect.size.height,
                                                          _recordButtonRect.size.width, 
                                                          _recordButtonRect.size.height);
                     }
                     completion:nil];
}

#pragma mark - PearlReveal delegate

- (void)torchShow:(bool)show {
    
    if (_videoManager.captureFlags & kDeviceCaptureCameraBack)
        show = NO;
    
    if (show) {
        
        AVCaptureDevice* device =[_videoManager videoDevice];
        if (![device isTorchModeSupported:AVCaptureTorchModeOn])
            return;
        
        
        _torchSwitch.alpha = 0.;
        _torchButton.alpha = 0.;
        _torchSwitch.hidden = NO;
        _torchButton.hidden = NO;
        
        [UIView animateWithDuration:.5 delay:0 options:AnimUserContinue
                         animations:^{
                             _torchSwitch.alpha = 1.;
                             _torchButton.hidden = 1;
                         }
                         completion:nil];
    }
    else {
        
        [UIView animateWithDuration:.5 delay:0  options:AnimUserContinue
                         animations:^{
                            _torchSwitch.alpha = 0;
                            _torchButton.alpha = 0;
                         }
                         completion:^(BOOL completed){
                             _torchSwitch.hidden = YES;
                            _torchButton.hidden = YES;
                         }];
    }
    
}

- (void)positionShow:(bool)show {
    
    if (show) {
        
        _cameraPosition.hidden = NO;
        
        [UIView animateWithDuration:.5 delay:0  options:AnimUserContinue
                         animations:^{  _cameraPosition.alpha = 1; }
                         completion:nil];
    }
    else {
        
        [UIView animateWithDuration:.5 delay:0  options:AnimUserContinue
                         animations:^        { _cameraPosition.alpha = 0;    }
                         completion:^(BOOL c){ _cameraPosition.hidden = YES; }];
    }
}

- (void)pearlRevealState:(RevealState)state center:(CGPoint)center_ {
    
    //LogCameraVC(@"pearlRevealState:%i center:(%.f,%.f)",state,center_.x, center_.y);

    // return; //TODO: redo
    
     switch (state) {
            
        case kRevealHidden: {
            
            _recordButton.center = center_;
            _recordButton.alpha = 0;
            _recordButton.hidden = NO;
            
            _stillVideo.center = center_;
            _stillVideo.alpha = 0;
            _stillVideo.hidden = NO;
            
            [UIView animateWithDuration:.25 delay:0 options:AnimUserContinue

                             animations:^{
                                 
                                 _cameraPosition.alpha = 1;
                                 if ([[_videoManager videoDevice] isTorchModeSupported:AVCaptureTorchModeOn]) {
                                 _torchSwitch.alpha = 1;
                                 _torchButton.alpha = 1;
                                 }
                                 
                                 _stillVideo.alpha = 1; //
                                 _stillVideo.transform = CGAffineTransformScale(CGAffineTransformIdentity,1,1);
                                 
                                 _recordButton.alpha = 1; //
                                 _recordButton.transform = CGAffineTransformScale(CGAffineTransformIdentity,1,1);
                             }
                             completion:nil];
            
            [self arrangeButtons]; 
            break;
        }
        case kRevealGrowing: {
            
            _stillVideo.transform   = CGAffineTransformScale(CGAffineTransformIdentity,.01,.01);
            _recordButton.transform = CGAffineTransformScale(CGAffineTransformIdentity,.01,.01);
              
            CGPoint newCenter = center_;
            
            [UIView animateWithDuration:.25 delay:0 options:AnimUserContinue
             
                             animations:^{
             
                                 _cameraPosition.alpha = 0;
                                 _torchSwitch.alpha = 0;
                                 _torchButton.alpha = 0;
                                 
                                 _stillVideo.center = newCenter;
                                 _stillVideo.alpha = 0;
                                 _stillVideo.transform = CGAffineTransformScale(CGAffineTransformIdentity,.05,.05);
                                 
                                 _recordButton.center = newCenter;
                                 _recordButton.alpha = 0;
                                 _recordButton.transform = CGAffineTransformScale(CGAffineTransformIdentity,.01,.01);
                             }
                             completion:^(BOOL compete){
                                 _stillVideo.hidden = YES;
                                 _recordButton.hidden = YES;
                             }];
            break;
        }
        default: break;
    }
}

- (void)showCameraOverlay:(bool)show {
    
    [self positionShow:show];
    [self torchShow:show];
}

#pragma mark - ThumbSliderDelegate

- (void)torchSliderAction {
    
    ///!!! [_videoManager setTorchLevel:_torchSwitch.position];
}


#pragma mark - touch button event

- (void)onCameraTorch {
    
    _torchButton.selected = !_torchButton.selected;
    CGFloat torchOn = (_torchButton.selected?1:0);
    [_videoManager setTorchLevel:torchOn];
}


- (void)onCameraPosition {
    
    ///!!! _torchSwitch.position = 0;
    if (_videoManager.captureFlags & kDeviceCaptureCameraFront) {
        _videoManager.captureFlags = kDeviceCaptureCameraBack;
       
    }
    else {
        _videoManager.captureFlags = kDeviceCaptureCameraFront;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_videoManager.captureFlags] forKey:kCaptureFlagsKey];
    
    if (_torchButton.selected) {
        
        [self onCameraTorch]; // turn torch off 
    }
    [self torchShow:(_videoManager.captureFlags & kDeviceCaptureCameraBack)];
    
}
- (void)recordButtonBlink {
    
    if (!self.videoRecording) {
        [_blinkTimer invalidate];
        _recButtonVideoOn.alpha = 0;
        return;
    }
    CFTimeInterval timeNow = CFAbsoluteTimeGetCurrent();
    CFTimeInterval deltaTime = timeNow - _blinkStartTime;
    
     double deltaTimeInt;
    double deltaTimeFrac = modf (deltaTime , &deltaTimeInt);
    NSString* secs = [NSString stringWithFormat:@"%.f",deltaTimeInt+1];
    if (deltaTimeInt >= 600) {
        [self onCameraRecord];
        [_blinkTimer invalidate];
        _recButtonVideoOn.alpha = 0;
        return;
    }
    else {
        _countDownLabel.text = secs;
        _recButtonVideoOn.alpha = fabs(1-deltaTimeFrac*2);  // reversable blink
    }
    
}

- (void)cameraControlRecordOn:(bool)on {
    
    //NSLog(@"%s:%i",sel_getName(_cmd),on);
    if (on) {
        
        //[_selectSound play];
        [VideoManager.shared  startWritingVideo];
        _blinkStartTime = CFAbsoluteTimeGetCurrent();
        _blinkTimer = [NSTimer scheduledTimerWithTimeInterval:1./30. 
                                                      target:self 
                                                    selector:@selector(recordButtonBlink) 
                                                    userInfo:nil 
                                                     repeats:YES];
    }
    else {
        
        [VideoManager.shared stopWritingVideo];
        [MenuDock.shared shrinkDock];
        /* Redo: sharekit want to pass the whole file in memory
         * [MenuChildShare.shared autoLaunchVideo];
         */
    }
}

- (void)snapshotDelegateImage:(UIImage*)image {
    
    // do something with captured image
    //[MenuDock.shared shrinkDock];
    //[self autoLaunchImage:image];
}



- (void)onCameraRecord {
    
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    NSNumber* num = [settings objectForKey:kInfoLockStatusKey];
    InfoLockStatus status = (num ? (InfoLockStatus)[num integerValue ]: kInfoLockOff);

    if (status == kInfoLockEverything) {
        
        UIAlertView* alert = [UIAlertView.alloc initWithTitle:@"Child Lock is On" 
                                                          message:(@"To allow recording and sharing, \nturn Child Lock off in Settings\n")
                                                         delegate:nil 
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"OK",nil];
        ((UILabel*)[[alert subviews] objectAtIndex:1]).textAlignment = NSTextAlignmentCenter;
        alert.alpha = 1;
        [alert show];
        
        return;
        
    }

     switch (_cameraMode) {
            
        case kCameraModeStill: {
            
            [_videoManager setSnapshotDelegate:self];
            break;    
        }
            
        case kCameraModeVideo: {
            
            static CFTimeInterval startTime = 0;
            CFTimeInterval timeNow = CFAbsoluteTimeGetCurrent();
            CFTimeInterval deltaTime = timeNow - startTime;
            
            if (deltaTime < 1) /* at least one second */
                return;
            
            startTime= timeNow;
 
            self.videoRecording = !self.videoRecording;
            
            _recButtonStill.alpha = 0;
            
            if (self.videoRecording) {
                
                 
                 [MenuDock.shared.parentNow.menuChild hideMenu];
                
                // this workaround for playing sound will unlock exposure settings
                // unworkable - even for autoexpose
                // [_videoManager setActive:NO]; 
                // [AlertSound.shared playAlways];
                // [_videoManager setActive:YES]; 
                
                _countDownLabel.text = @"0";
                _recButtonVideoOn.alpha = 1;
                [UIView animateWithDuration:.5 delay:0 options:AnimUserContinue
                 
                                 animations:^{ 
                                     _cameraPosition.alpha = 0;
                                     _stillVideo    .alpha = 0; 
                                     
                                     _recButtonVideoOn.center   = CGPointMake(_recordButton.frame.size.width/4,  _recordButton.frame.size.height/2);  
                                     _recButtonVideoOff.center  = CGPointMake(_recordButton.frame.size.width/4,  _recordButton.frame.size.height/2);
                                     _countDownLabel.center     = CGPointMake(_recordButton.frame.size.width/4*3,_recordButton.frame.size.height/2); 
                                     _countDownLabel.alpha      = 1;
                                 }
                                 completion:^(BOOL completed){ 
                                     
                                    [self cameraControlRecordOn:self.videoRecording];
                                 }];
                [self positionShow:NO];
            }
            else {
 
                [self cameraControlRecordOn:self.videoRecording];
                
                [UIView animateWithDuration:.25 delay:0 options:AnimUserContinue
                 
                                 animations:^{ 
                                     _cameraPosition.alpha = 1;
                                     _stillVideo    .alpha = 1;

                                     _recButtonVideoOn.center   = CGPointMake(_recordButton.frame.size.width/2,_recordButton.frame.size.height/2);
                                     _recButtonVideoOff.center  = CGPointMake(_recordButton.frame.size.width/2,_recordButton.frame.size.height/2);
                                     _countDownLabel.center     = CGPointMake(_recordButton.frame.size.width/2,_recordButton.frame.size.height/2);
                                     _countDownLabel.alpha      = 0;

                                 }
                                 completion:nil];

                [self positionShow:YES];
                
                if (_torchButton.selected) {
                    
                    [self onCameraTorch]; // turn torch off 
                }
            }
            break;
        }            
    }
}

- (void)setCameraMode:(CameraMode)cameraMode {
    
    _cameraMode = cameraMode;
    
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:[NSNumber numberWithInt:_cameraMode] forKey:kInfoCameraToggleVideoKey];
    [settings synchronize];
    
    switch (_cameraMode) {
            
        case kCameraModeVideo: {
            
            
            [UIView animateWithDuration:.5 delay:0 options:AnimUserContinue
             
                             animations:^{ 
                                 _recButtonStill   .alpha = 0;
                                 _recButtonVideoOn .alpha = 0;                                  
                                 _recButtonVideoOff.alpha = 1; 
                                 _countDownLabel   .alpha = 0;
                                 _toggleThumb.frame = _toggleThumbRight;
                             }
                             completion:nil];
            break;
        }
        case kCameraModeStill: {
            
            float delay = 0.;
            
            if (self.videoRecording) {
                
                [self onCameraRecord];
                delay = 1.;
            }

            [UIView animateWithDuration:.5 delay:delay options:AnimUserContinue
             
                             animations:^{ 
                                 _recButtonStill   .alpha = 1;
                                 _recButtonVideoOff.alpha = 0;                                  
                                 _recButtonVideoOn .alpha = 0;
                                 _countDownLabel   .alpha = 0;
                                 
                                 _toggleThumb.frame = _toggleThumbLeft;
                             }
                             completion:nil];
            break;
        }
    }
    _stillVideo.selected = !_stillVideo.selected;     
}

- (void)onStillVideo {
    
    switch (_cameraMode) {
            
        case kCameraModeStill: self.cameraMode  = kCameraModeVideo; break;
        case kCameraModeVideo: self.cameraMode  = kCameraModeStill; break;
        default: break;
    }
    _stillVideo.selected = !_stillVideo.selected;     
}

#pragma mark - Touches

- (void)lockExposure {
    
    if (_exposurePoint.x != 0 && 
        _exposurePoint.y != 0) {
        
        [_videoManager lockWhiteAndExposureBalanceAtPoint:_exposurePoint];
        
    }
}

- (CGPoint)orientedExposurePointFromLocation:(CGPoint)location {
    
    CGPoint exposurePoint;
    CGSize size = [ScreenView shared].bounds.size;
    exposurePoint.x =    location.x/size.width;
     if (_videoManager.captureFlags & kDeviceCaptureCameraBack)
         exposurePoint.y = location.y/size.height;
    else 
        exposurePoint.y = 1.-location.y/size.height;
    
    //NSLog(@"location(%.f,%.f) size(%.f,%.f) exposure(%.2f,%.2f)", location.x, location.y, size.width,size.height, exposurePoint.x, exposurePoint.y);
    
    return exposurePoint;
}

- (void)animateCross {
    
    _cameraCrossCircle.center = _beginTouchLocation;
    _cameraCrossEye.center    = _beginTouchLocation;
    _cameraCrossLock.center   = _beginTouchLocation;
    
    if (!self.touching) {
        
        [UIView animateWithDuration:.5 delay:0 options:AnimUserContinue  | UIViewAnimationOptionCurveEaseIn
         
                         animations:^{ 
                             
                             _cameraCrossEye.alpha = 0;
                         }
                         completion:^(BOOL complete){ [_cameraCrossEye removeFromSuperview];}];
    } else {
        
        [_cameraCrossEye removeFromSuperview]; // change viewing order
        [self addSubview:_cameraCrossCircle];
        [self addSubview:_cameraCrossLock]; // fade under Eye
        [self addSubview:_cameraCrossEye];
        
        CGAffineTransform transformRotate  = [self transformForOrientation];
        CGAffineTransform transformOutside = CGAffineTransformScale(transformRotate, 8, 8);
        CGAffineTransform transformInside  = CGAffineTransformScale(transformRotate, .5, .5);
        
        _cameraCrossCircle.transform = transformOutside;
        _cameraCrossCircle.alpha = 0;
        _cameraCrossLock.transform = transformInside;
        _cameraCrossLock.alpha = 0;
        
        [UIView animateWithDuration:.5 delay:0 options:AnimUserContinue
                         animations:^{
                             _cameraCrossCircle.alpha = 1;
                             _cameraCrossCircle.transform = transformInside;
                         }
                         completion:^(BOOL compete){
                             
                             [UIView animateWithDuration:.5 delay:0 options:AnimUserContinue
                                              animations:^{
                                                  _cameraCrossEye.alpha  = 0.;
                                                  _cameraCrossLock.alpha = 1.;
                                              }
                                              completion:^(BOOL compete){
                                                  
                                                  [_cameraCrossCircle removeFromSuperview];
                                                  [_cameraCrossEye    removeFromSuperview];
                                                  [_cameraCrossLock   removeFromSuperview];
                                                  [self lockExposure];
                                                  
                                              }];
                         }];
    }
}

- (void)animateEye {
    
    CGAffineTransform transformRotate  = [self transformForOrientation];
    CGAffineTransform transformInside  = CGAffineTransformScale(transformRotate, .5, .5);
    
    _cameraCrossEye.center    = _beginTouchLocation;
    [self addSubview:_cameraCrossEye];
    
    _cameraCrossEye.transform = transformInside;
    _cameraCrossEye.alpha = 0;
    
    [UIView animateWithDuration:.25 delay:0 options:AnimUserContinue  | UIViewAnimationOptionCurveEaseIn
                     animations:^{_cameraCrossEye.alpha = 1;}
                     completion:^(BOOL complete){  [NSTimer scheduledTimerWithTimeInterval:.25 target:self selector:@selector(animateCross) userInfo:nil repeats:NO];	}];
    
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    RevealState revealState = MenuDock.shared.state;
    if (revealState != kRevealHidden)
        return;
    
    self.touching = YES;
    
    double thisTime = CFAbsoluteTimeGetCurrent();
    double deltaTime = thisTime - _touchBeginTime;    
    _touchBeginTime = thisTime;    
    
    if (deltaTime > .5) {
        
        _touchDuration = 0;
        
        _beginTouchLocation = [[touches anyObject] locationInView:self];
        _paintTouchLocation = [[touches anyObject] locationInView:[ScreenView shared]];
        _exposurePoint = [self orientedExposurePointFromLocation:_paintTouchLocation];
        [_videoManager unlockWhiteAndExposureBalanceAtPoint:_exposurePoint];
        
        _exposureMode = kExposureLocked;
        [self animateEye];		
        
    } else {
        
        _exposureMode = kExposureAuto;
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    
    CFTimeInterval thisTime =CFAbsoluteTimeGetCurrent();
    _touchDuration = thisTime - _touchBeginTime;
    self.touching = NO;
    
    [super touchesEnded:touches withEvent:event];
    
}


@end
