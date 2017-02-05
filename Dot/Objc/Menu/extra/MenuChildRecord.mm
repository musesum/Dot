
#import "MenuChildRecord.h"
#import "VideoManager.h"
#import "SkyPatch.h"

@implementation MenuChildRecord

- (id)initWithPatch:(SkyPatch*)patch_ {
    
    CGRect frame = CGRectZero;
    
    self = [super initWithFrame:frame title:@"record"];
    
    self.recordButton = [UIButton.alloc initWithFrame:CGRectMake(0,0,128,128)];
    
    [_recordButton setImage:[UIImage imageNamed:@"Record_128.png"] forState:UIControlStateNormal];
    [_recordButton addTarget:self action:@selector(onRecordButton) forControlEvents:UIControlEventTouchUpInside];
    _recordButton.showsTouchWhenHighlighted = YES;
    [self addSubview:_recordButton];
    return self;
}


- (void)recordButtonBlink {
    
    if (!_videoRecording) {
        _parentImageView.alpha = 1;
        [_blinkTimer invalidate];
        _blinkTimer = 0;
        return;
    }

    CFTimeInterval timeNow = CFAbsoluteTimeGetCurrent();
    CFTimeInterval deltaTime = timeNow - _blinkStartTime;
    
    double deltaTimeInt;
    double deltaTimeFrac = modf (deltaTime , &deltaTimeInt);
    NSString* secs = [NSString stringWithFormat:@"%.f",deltaTimeInt+1];
 
    if (deltaTimeInt >= 600) {
        
        [self recordOff];
        [_blinkTimer invalidate];
        _parentImageView.alpha = 1;
        return;
    }
    else {
        _countDownLabel.text = secs;
        _parentImageView.alpha = fabs(1-deltaTimeFrac*2);  // reversable blink
    }
}

- (void)recordOn {

    NSLog(@"MenuChildRecord::%s",sel_getName(_cmd));

    self.parentImageView = self.menuParent.imageView;
    _parentImageView.image = [UIImage imageNamed:@"Recording_128.png"];
    _videoRecording = YES;
    
    [VideoManager.shared  startWritingVideo];
    _blinkStartTime = CFAbsoluteTimeGetCurrent();
    _blinkTimer = [NSTimer scheduledTimerWithTimeInterval:1./30.
                                                   target:self
                                                 selector:@selector(recordButtonBlink)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void)recordOff {
    
    if (_videoRecording) {
        
        _videoRecording = NO;
        [VideoManager.shared stopWritingVideo];
        
        UIAlertView* alertView = [UIAlertView.alloc initWithTitle:@"Recording Done"
                                                            message:@"Saved to Photos Video"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        _parentImageView.image = [UIImage imageNamed:@"Record_128.png"];
        _parentImageView.alpha = 1;
    }
}

- (void) recordToggle {
    
    if (_videoRecording) {
        [self recordOff];
    }
    else {
        [self recordOn];
    }
}
#pragma mark - Menu Parent Dock

- (void)MenuParentSingleTap {
}

- (void)MenuParentDoubleTap {

    [self recordToggle];
}


@end
