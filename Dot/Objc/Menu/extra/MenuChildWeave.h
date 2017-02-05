#import "MenuChildBase.h"
#import "Tr3.h"

@class ThumbBox;
@class ThumbSwitch;

@interface MenuChildWeave : MenuChildBase {

    ThumbSwitch* _ruleOn;
    ThumbBox* _spreadBox;
    ThumbBox* _divideBox;
}

- (id)initWithPatch:(SkyPatch*)patch;

@end
