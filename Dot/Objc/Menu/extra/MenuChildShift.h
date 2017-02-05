#import "MenuChildPalette.h"
#import "Tr3.h"

@class ThumbSegment;
@class ThumbSlider;
@class ThumbSwitch;
@class ThumbTwist;
@class ThumbXY;

@interface MenuChildShift : MenuChildBase {

    ThumbSwitch* _ruleOn;
    ThumbTwist*  _modified;
    ThumbSwitch* _brushTilt;
    ThumbXY*    _shiftBox;
    ThumbSwitch* _accelTilt;
}

@end
