
#import "ThumbTwist.h"
#import "ThumbFlip.h"

#define LogThumbTwist(...) //DebugLog(__VA_ARGS__)

@implementation ThumbTwist

#pragma mark - init

- (void) updateSub {

    CGFloat h = _frame.size.height;
    CGFloat w = _frame.size.width;
    CGFloat d = _radius*2; // diameter
    
    _thumbFlip = [ThumbFlip.alloc initWithFrame:CGRectMake(0,0,d,d) back:_iconOff front:_iconOn];
    [_thumbFlip makeTwisted];
    _thumb = _thumbFlip;
    
    [self addSubview:_thumbFlip];
}

@end
