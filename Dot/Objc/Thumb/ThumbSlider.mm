
#import "ThumbBase.h"
#import "ThumbSlider.h"
#import "ThumbFlip.h"
#import "MuDrawCircle.h"
#import "Tr3Val.h"
#import "Tr3.h"
#import "Tr3Cache.h"

#define PrintThumbSlider(...) DebugPrint(__VA_ARGS__)

@implementation ThumbSlider


- (void) updateSub {

    CGFloat h = _frame.size.height;
    CGFloat w = _frame.size.width;
    CGFloat d = _radius*2;

    _bezel = (w == h
              ? [UIView.alloc  initWithFrame:CGRectMake(0,0,w,h)]
              : [MuBezel.alloc initWithFrame:CGRectMake(0,0,w,h)]);
    
    _thumbFlip = [ThumbFlip.alloc initWithFrame:CGRectMake(0,0,d,d) back:_iconOff front:_iconOn];
    _thumb = _thumbFlip;
    
    [self addSubview:_bezel];
    [self addSubview:_thumbFlip];
}

- (void) updateMaster {
    
    if (_tr3Master) {
    
        _state = (int)*_tr3Master ? kMaster : kSlave;
        
        switch (_state) {
                
            case kSlave:    _thumbFlip.flipped = NO;  break;
            case kMaster:   _thumbFlip.flipped = YES; break;
        }
    }
}

- (void)setValue:(CGPoint)value_ {
    
    if (_value.x != value_.x) {
        _value = value_;
        [self updateCursor];
        Tr3Cache::changeRange01(_tr3Value,_value.x);
    }
}




@end
