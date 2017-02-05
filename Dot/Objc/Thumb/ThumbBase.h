#import "Tr3Types.h"
#import "ThumbState.h"

struct Tr3;
struct Tr3CallData;

@interface ThumbBase : UIView {

    NSString* _title;
    Tr3*      _tr3Value;
    Tr3*      _tr3Master;
    Tr3*      _tr3Default;

    CGRect      _frame;
    CGFloat     _radius;
    CGPoint     _minXY;
    CGPoint     _maxXY;
    CGPoint     _cursor;
    CGPoint     _range;
    
    NSString*   _iconNameOff;
    NSString*   _iconNameOn;
    UIImage*    _iconOn;
    UIImage*    _iconOff;
    ThumbState  _state;
    
    UIView*     _thumb;
    
    CGPoint     _value;     // 0...1 value
    CGPoint     _prevVal;   // 0...1 during animation
    CGPoint     _nextVal;   // 0...1 during animation
    CGPoint     _startVal;  // 0...1 value starting position
    CGPoint     _tap2Val; // position(s) for double tap

    CFTimeInterval  _touchTime;
    CFTimeInterval  _tap2Time;
    bool            _tap2ing;
    CGFloat         _lag;
}
@property bool animating;

- (id)initWithTr3:(Tr3*)tr3; // init via tr3 hierarchy
- (void)updateBase;
- (void)updateSub;                      // override this
- (void)updateCursor;                   // shift position of _thumb on UI
- (void)animateCursor;

void Tr3ThumbValue(Tr3*from,Tr3CallData*data); // callback
void Tr3ThumbMaster(Tr3*from,Tr3CallData*data); // callback
void Tr3ThumbDefault(Tr3*from,Tr3CallData*data); // callback

- (void) setValue:(CGPoint)value_;
- (void) updateValue;   // update after Tr3ThumbValue callback
- (void) updateMaster;  // update after Tr3ThumbMaster callback
- (void) updateDefault; // update after Tr3ThumbDefault callback


@end
