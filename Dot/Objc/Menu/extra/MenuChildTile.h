#import "main.h"
#import "MenuChildBase.h"

@class ThumbBox;
@class ThumbSwitch;
@class ThumbTwist;
@class ThumbSlider;


@interface MenuChildTile: MenuChildBase {
    
    ThumbSwitch* _ruleOn;
    ThumbTwist* _modified;
    ThumbBox* _mirrorBox;
    ThumbBox* _repeatBox;
    UIButton* _brushZeroButton;
}
- (id)initWithPatch:(SkyPatch*)patch;

@end
