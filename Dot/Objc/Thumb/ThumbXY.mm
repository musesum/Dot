
#import "ThumbXY.h"
#import "MuDrawCircle.h"
#import "Tr3.h"

#define LogThumbXY(...) //DebugLog(__VA_ARGS__)


@implementation ThumbXY

- (void) updateSub {

    CGFloat h = _frame.size.height;
    CGFloat w = _frame.size.width;
    CGFloat d = _radius*2;
    
    _box = [MuDrawBox.alloc initWithFrame:CGRectMake(0,0,w,h) cornerRadius:_radius];
    
    _thumbBox =  [UIImageView.alloc initWithImage:_iconOn];
    _thumbBox.frame = CGRectMake(0,0,d,d);
    _thumb = _thumbBox;

    [self addSubview:_box];
    [self addSubview:_thumb ];
 }


/* change icon based on whether master or slave
 * There is always _iconOn, with optional _iconOff
 * if no _iconOff, then use alpha for _iconOn to grey out
 */
- (void)updateMaster {
    
    if (_tr3Master) {
        
        _state = (int)*_tr3Master ? kMaster : kSlave;
        
        switch (_state) {
                
            case kSlave:
                
                if (_iconOff)   { _thumbBox.image = _iconOff; }
                else            { _thumbBox.alpha = .5; }
                break;
                
            case kMaster:
                
                if (_iconOff)  { _thumbBox.image = _iconOn; }
                else           { _thumbBox.alpha = 1;}
                break;
        }
    }
}


@end
