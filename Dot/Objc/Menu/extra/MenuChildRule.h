#import "MenuChildBase.h"
#import "Tr3.h"

@class ThumbSegment;
@class ThumbSlider;
@class ThumbSwitch;
@class ThumbTwist;

@interface MenuChildRule : MenuChildBase {
    
    Tr3* _cellNow;
    Tr3* _cellRuleOn;
    ThumbSwitch* _ruleOn;
    ThumbTwist* _modified;
    ThumbSegment *_versionSegment;
    ThumbSlider *_rulePlaneSlider;
    UIButton *_brushZeroButton;
    UIButton* _brushNineButton;
}
- (id)initWithPatch:(SkyPatch*)patch_;
@end
