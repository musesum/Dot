#import "ColorRGBA.h"


@interface MuDrawDot : UIView {

    CGFloat _radius;
    ColorRGBA _color;

    CFTimeInterval _touchBeginTime; 
}

@property(nonatomic) CGFloat radius;
@property(nonatomic) ColorRGBA color;

- (id)initWithFrame:(CGRect)frame_;

@end
