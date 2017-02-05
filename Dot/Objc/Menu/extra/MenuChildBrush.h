#import "main.h"
#import "MenuChildPalette.h"
#import "Tr3.h"

@class ThumbSegment;
@class ThumbSlider;
@class ThumbSwitch;

@interface MenuChildBrush : MenuChildPalette {
    
    UIButton* _brushZeroButton;
    UIButton* _brushNineButton;
    ThumbSlider* _brushSize;
    ThumbSwitch* _brushPress;
}

- (id)initWithPatch:(SkyPatch*)patch_;

@end
