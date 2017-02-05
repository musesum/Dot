
#import <UIKit/UIKit.h>
#import "MenuDock.h"
#import "Tr3.h"
#import "DeviceCaptureFlags.h"
#import "ThumbSwitch.h"


@class VideoManager;

typedef enum {
    kCameraModeVideo,
    kCameraModeStill
} CameraMode;

typedef enum {
    kExposureAuto,
    kExposureLocked,
} ExposureMode;

#define kCameraModeKey             @"CameraMode"
#define kCaptureFlagsKey           @"CaptureFlags"
#define kInfoCameraToggleVideoKey  @"kInfoCameraToggleVideo"

@interface CameraView: UIView {
    
    CGRect _stillVideoRect;
    CGRect _torchButtonRect;
    CGRect _torchSliderRect;

    UIImageView* _toggleStill;
    UIImageView* _toggleVideo;
    UIImageView* _toggleThumb;
    CGRect       _toggleThumbLeft;
    CGRect       _toggleThumbRight;
    
    CGRect       _recordButtonRect;
    UIImageView* _recButtonVideoOn;
    UIImageView* _recButtonVideoOff;
    UIImageView* _recButtonStill;
    
    UIImageView* _cameraCrossCircle;
    UIImageView* _cameraCrossEye;
    UIImageView* _cameraCrossLock;

    CGRect       _cameraPositionRect;
    UIImageView* _cameraPositionCamera;
 
    CGPoint     _exposurePoint;
    CGPoint     _beginTouchLocation; // this view touch location
    CGPoint     _paintTouchLocation; // camera oriented touch location
    double      _touchBeginTime; 
    double      _touchDuration;
    
    NSTimer*       _blinkTimer;
    CFTimeInterval _blinkStartTime;
    
    UILabel*  _countDownLabel;
    UIButton* _stillVideo;
    UIButton* _recordButton;
    UIButton* _cameraPosition;
    UIButton* _torchButton;
    ThumbSwitch* _torchSwitch;
    CameraMode _cameraMode;
    ExposureMode _exposureMode;
}

@property bool touching;
@property bool videoRecording;
@property (nonatomic,weak)VideoManager* videoManager;

- (id)initWithDelegate:(id)delegate_ captureFlags:(DeviceCaptureFlags)captureFlags;
- (void)showCameraOverlay:(bool)show;

@end
