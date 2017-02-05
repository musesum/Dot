#import "MenuChildBase.h"
#import "MuPicker.h"

@class MuPalettePicker;
@class ThumbSlider;
@class ThumbSliderParent;
@class ScrubView;
@class MuNavRotateC;


typedef enum {
    kLeftButton = 0,
    kRightButton = 1
} LeftRightTag;


@interface MenuChildPalette : MenuChildBase {

    Tr3* _tr3MainFrame;
    MuPalettePicker* _palPicker;
    ThumbSlider* _palXfadeSlider;
    NSMutableArray* _palButtons;
    ScrubView* _scrubView;
    UIButton* _shiftLeft;
    UIButton* _shiftRight;
    ThumbSlider* _realpalSlider;
    ThumbSliderParent* _brushIndexSlider;
    
    CGFloat _palCycleOffset;
    Pals *_pals;
}

- (id)initWithPatch:(SkyPatch*)patch;
- (void)initPalShiftLeft:(CGRect)frame;
- (void)initPalShiftRight:(CGRect)frame;
- (void)initPalScrub:(CGRect)frame;
- (void)updateScrubViewImage;
- (void)ScrubViewUpdate;
- (void)ScrubViewReset;

@end
