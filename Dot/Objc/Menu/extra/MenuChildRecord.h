
#import "MenuChild.h"

@class SkyPatch;

@interface MenuChildRecord : MenuChild {
    
    CGRect       _cameraPositionRect;
    UIImageView* _cameraPositionCamera;
    
    NSTimer*       _blinkTimer;
    CFTimeInterval _blinkStartTime;
    
     bool _videoRecording;
}

@property (nonatomic,strong) UILabel*  countDownLabel;
@property (nonatomic,strong) UIButton* recordButton;
@property (nonatomic,strong) UIImageView*parentImageView;

- (id)initWithPatch:(SkyPatch*)patch_;

@end
