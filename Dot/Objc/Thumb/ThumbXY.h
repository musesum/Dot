
#import "ThumbBase.h"

@class MuDrawBox;

@interface ThumbXY : ThumbBase {
    MuDrawBox *_box;
    UIImageView *_thumbBox;
}

- (void) updateSub;
- (void) updateMaster;

@end
