#import "ThumbBase.h"

@class ThumbFlip;
@class MuBezel;
struct Tr3;

@interface ThumbSlider : ThumbBase {
    
    ThumbFlip* _thumbFlip;
    UIView* _bezel;
}
- (void)updateSub;
- (void)updateMaster;
- (void)setValue:(CGPoint)value_;

@end
