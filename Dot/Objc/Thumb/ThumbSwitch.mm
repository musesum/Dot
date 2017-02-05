
#import "ThumbSwitch.h"
#import "ThumbSlider.h"
#import "ThumbFlip.h"
#import "Tr3.h"

#define LogThumbSwitch(...) //DebugLog(__VA_ARGS__)

@implementation ThumbSwitch

- (void)setCursor:(CGPoint)location_ {
    
    _prevVal = _value;
    _nextVal = _value.x <.5 ? CGPointMake(1,1) :  CGPointMake(0,0);
    [self animateCursor];
    _thumbFlip.flipped = _nextVal.x > .5;
}

- (void)updateMaster {
}


- (void)setValue:(CGPoint)value_ {
    
    [super setValue:value_];
    _thumbFlip.flipped = value_.x > .5;
}


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
 
    CFTimeInterval thisTime = CFAbsoluteTimeGetCurrent();
    double deltaTime = thisTime - _touchTime;
    _touchTime = thisTime;
    
    if (deltaTime > .5) {
        
         [self setValue : _value.x > .5 ? CGPointMake(0, 0) : CGPointMake(1, 1)];
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
}


@end
