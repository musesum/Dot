#import "main.h"
#import "ColorRGBA.h"

@interface MuDrawBox : UIView

- (id)initWithFrame:(CGRect)frame cornerRadius:(CGFloat)cornerRadius_;
@property(nonatomic) CGFloat cornerRadius;

@end

@interface MuBezel : UIView
@end


@interface MuDrawCircle : UIView {
    
    CGFloat _width;
    ColorRGBA _color;
}
@property(nonatomic) CGFloat width;
@property(nonatomic) ColorRGBA color;
@end


#pragma mark - bubble balloon

@interface MuDrawBubble : UIView {
    
    CGRect _fromFrame;
    CGFloat _cornerRadius;
    CGFloat _cornerArrowRadius;
    CGFloat _arrowHeight;
    CGFloat _arrowWidth;
    CGPoint _viewPoint;
    CGPoint _arrowPoint;
    CGPoint _arrowMid;
}
/* example:
 * MuDrawBubble* bubble = [[MuDrawBubble.alloc initWithSize:CGSizeMake(192, 64) radius:32. fromView:_menuPearl] retain];
 * [self.window addSubview:bubble];
 */

- (id)initWithSize:(CGSize)size radius:(CGFloat)radius fromView:(UIView*)fromView;

@end
