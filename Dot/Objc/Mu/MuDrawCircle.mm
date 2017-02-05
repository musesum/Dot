
#import "MuDrawCircle.h"
#import <QuartzCore/CAShapeLayer.h>
#import "OrienteDevice.h"

@implementation MuDrawBox

- (id)initWithFrame:(CGRect)frame cornerRadius:(CGFloat)cornerRadius_ {
    
    self = [super initWithFrame:frame];
    _cornerRadius = cornerRadius_;
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    CGSize  size = self.frame.size;
    CGFloat h = size.height;
    CGFloat w = size.width;
    CGFloat r = _cornerRadius;
    
    CGPoint p1 = CGPointMake(  r,  r);
    CGPoint p2 = CGPointMake(w-r,  r);
    CGPoint p3 = CGPointMake(w-r,h-r);
    CGPoint p4 = CGPointMake(  r,h-r);
    
    CGPoint q1 = CGPointMake(  0,   r);
    CGPoint q2 = CGPointMake(  r, 0  );
    CGPoint q3 = CGPointMake(w-r, 0  );
    CGPoint q4 = CGPointMake(  w,   r);
    CGPoint q5 = CGPointMake(  w, h-r);
    CGPoint q6 = CGPointMake(w-r, h  );
    CGPoint q7 = CGPointMake(  r, h  );
    CGPoint q8 = CGPointMake(  0, h-r);
    
    [path moveToPoint:q1];      [path addArcWithCenter:p1 radius:r startAngle:-2*M_PI_2 endAngle:-1*M_PI_2 clockwise:YES];
    [path addLineToPoint:q3];   [path addArcWithCenter:p2 radius:r startAngle:-1*M_PI_2 endAngle: 0*M_PI_2 clockwise:YES];
    [path addLineToPoint:q5];   [path addArcWithCenter:p3 radius:r startAngle: 0*M_PI_2 endAngle: 1*M_PI_2 clockwise:YES];
    [path addLineToPoint:q7];   [path addArcWithCenter:p4 radius:r startAngle: 1*M_PI_2 endAngle: 2*M_PI_2 clockwise:YES];
    [path closePath];
    
    [[UIColor colorWithWhite:1 alpha:.5] setStroke];
    path.lineWidth = 2;
    [path stroke];
    
    //    maskLayer.strokeColor = [[UIColor colorWithWhite:.5 alpha:1] CGColor];
    maskLayer.fillColor = [[UIColor colorWithWhite:0 alpha:.20] CGColor];
    maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
    maskLayer.path = [path CGPath];
    
    UIView* superview = [self superview];
    [self removeFromSuperview];
    self.layer.mask = maskLayer;
    [superview insertSubview:self atIndex:0];
}


@end

@implementation MuBezel

- (void)drawRect:(CGRect)rect {
    
    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    CGSize  size = self.frame.size;
    CGFloat h = size.height;
    CGFloat w = size.width;
    CGFloat r = MIN(h,w)/2;
    
    CGPoint p1 = CGPointMake(  r,  r);
    CGPoint p2 = CGPointMake(w-r,  r);
    CGPoint p3 = CGPointMake(w-r,h-r);
    CGPoint p4 = CGPointMake(  r,h-r);
    
    CGPoint q1 = CGPointMake(  0,   r);
    CGPoint q2 = CGPointMake(  r, 0  );
    CGPoint q3 = CGPointMake(w-r, 0  );
    CGPoint q4 = CGPointMake(  w,   r);
    CGPoint q5 = CGPointMake(  w, h-r);
    CGPoint q6 = CGPointMake(w-r, h  );
    CGPoint q7 = CGPointMake(  r, h  );
    CGPoint q8 = CGPointMake(  0, h-r);
    
    [path moveToPoint:q1];      [path addArcWithCenter:p1 radius:r startAngle:-2*M_PI_2 endAngle:-1*M_PI_2 clockwise:YES];
    [path addLineToPoint:q3];   [path addArcWithCenter:p2 radius:r startAngle:-1*M_PI_2 endAngle: 0*M_PI_2 clockwise:YES];
    [path addLineToPoint:q5];   [path addArcWithCenter:p3 radius:r startAngle: 0*M_PI_2 endAngle: 1*M_PI_2 clockwise:YES];
    [path addLineToPoint:q7];   [path addArcWithCenter:p4 radius:r startAngle: 1*M_PI_2 endAngle: 2*M_PI_2 clockwise:YES];
    [path closePath];
 
    [[UIColor colorWithWhite:1 alpha:.5] setStroke];
    path.lineWidth = 2;
    [path stroke];
    
//    maskLayer.strokeColor = [[UIColor colorWithWhite:.5 alpha:1] CGColor];
    maskLayer.fillColor = [[UIColor colorWithWhite:0 alpha:.20] CGColor];
    maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
    maskLayer.path = [path CGPath];
    
    UIView* superview = [self superview];
    [self removeFromSuperview];
    self.layer.mask = maskLayer;
    [superview insertSubview:self atIndex:0];
}


@end


@implementation MuDrawCircle

@synthesize width = _width;
@synthesize color = _color;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    self.opaque = NO;
    self.userInteractionEnabled = YES;
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGRect drawRect = CGRectMake(_width, _width, 
                                 self.frame.size.width-2*_width, 
                                 self.frame.size.height-2*_width);
    CGContextSetRGBStrokeColor(contextRef, _color.red, _color.green, _color.blue, 1);
    CGContextSetLineWidth(contextRef,_width);
    CGContextStrokeEllipseInRect(contextRef, drawRect);
}

@end

#pragma mark - bubble balloon

@implementation MuDrawBubble

- (id)initWithSize:(CGSize)size radius:(CGFloat)radius fromView:(UIView*)fromView {
    
    _cornerRadius = radius;
    _cornerArrowRadius = _cornerRadius;
    _arrowHeight = 16;
    _arrowWidth = _arrowHeight;
    CGFloat radii = _arrowHeight*2+_cornerRadius*2;
    
    if ( radii > size.width) {
        CGFloat ratio = size.width/radii;
        _cornerArrowRadius *= ratio;
        _arrowWidth *= ratio;
    }
    _fromFrame = fromView.frame;
    
    _viewPoint = CGPointMake(_fromFrame.origin.x+_fromFrame.size.width/2,
                              _fromFrame.origin.y);
   
    CGRect frame = CGRectMake(_viewPoint.x-size.width/2,
                              _viewPoint.y-size.height-_arrowHeight,
                              size.width,
                              size.height+_arrowHeight);
    
    CGSize boundSize = UIScreen.mainScreen.fixedCoordinateSpace.bounds.size;
    if (frame.origin.x < 0) {
        frame.origin.x = 0;
    }
    else if (frame.origin.x+frame.size.width > boundSize.width) {
        frame.origin.x = boundSize.width - frame.size.width;
    }
    _arrowPoint = CGPointMake(_viewPoint.x-frame.origin.x, _viewPoint.y-frame.origin.y);
    _arrowMid   = CGPointMake(_arrowPoint.x, _arrowPoint.y-_arrowHeight);
    CGFloat minEdge = _cornerArrowRadius+_arrowWidth;

    if (minEdge > _arrowMid.x) {
        
        _arrowMid.x=minEdge;
        CGFloat fromRadius = _fromFrame.size.height/2;
        CGPoint fromCenter = CGPointMake(fromRadius, _arrowPoint.y+fromRadius);
        CGFloat radiusRatio = fromRadius/(fromRadius+_arrowHeight);
        CGSize deltaSize = CGSizeMake((_arrowMid.x-fromCenter.x)*radiusRatio,
                                      (_arrowMid.y-fromCenter.y)*radiusRatio);
        
        _arrowPoint = CGPointMake(fromCenter.x+deltaSize.width,
                                  fromCenter.y+deltaSize.height);
    }
    
    else if  (minEdge > frame.size.width - _arrowMid.x) {
        
        _arrowMid.x = frame.size.width - minEdge;
        CGFloat fromRadius = _fromFrame.size.height/2;
        CGPoint fromCenter = CGPointMake(frame.size.width-fromRadius, _arrowPoint.y+fromRadius);
        CGFloat radiusRatio = fromRadius/(fromRadius+_arrowHeight);
        CGSize deltaSize = CGSizeMake((_arrowMid.x-fromCenter.x)*radiusRatio,
                                      (_arrowMid.y-fromCenter.y)*radiusRatio);
        
        _arrowPoint = CGPointMake(fromCenter.x+deltaSize.width,
                                  fromCenter.y+deltaSize.height);
    }
    self = [super initWithFrame:frame];
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    CGSize  size = self.frame.size;
    CGFloat r = _cornerRadius;
    CGFloat ra = _cornerArrowRadius;
    
    CGPoint p1 = CGPointMake(0, 0);
    CGPoint p2 = CGPointMake(size.width, 0);
    CGPoint p3 = CGPointMake(p2.x, size.height-_arrowHeight);
    CGPoint p4 = CGPointMake(p1.x, p3.y);
    
    CGPoint q1s = CGPointMake(p1.x   , p1.y+r);
    CGPoint q1e = CGPointMake(p1.x+r , p1.y  );
    CGPoint q2s = CGPointMake(p2.x-r , p2.y  );
    CGPoint q2e = CGPointMake(p2.x   , p2.y+r);
    CGPoint q3s = CGPointMake(p3.x   , p3.y-r);
    CGPoint q3e = CGPointMake(p3.x-ra, p3.y  );
    CGPoint q4s = CGPointMake(p4.x+ra, p4.y  );
    CGPoint q4e = CGPointMake(p4.x   , p4.y-r);
   
    CGPoint la3 = CGPointMake(_arrowMid.x+_arrowWidth,  _arrowMid.y);
    CGPoint la4 = CGPointMake(_arrowMid.x-_arrowWidth,  _arrowMid.y);

    if (q3e.x < la3.x) {
        q3e.x = (q3e.x+la3.x)/2;
        la3.x = q3e.x;
    }
    
    if (q4s.x > la4.x) {
        q4s.x = (q4s.x+la4.x)/2;
        la4.x = q4s.x;
    }
    
    [path moveToPoint:q1s];      [path addQuadCurveToPoint:q1e controlPoint:p1];
    [path addLineToPoint:q2s];   [path addQuadCurveToPoint:q2e controlPoint:p2];
    [path addLineToPoint:q3s];   [path addQuadCurveToPoint:q3e controlPoint:p3];
 
    [path addLineToPoint:la3];
    [path addQuadCurveToPoint:_arrowPoint controlPoint:_arrowMid];
    [path addQuadCurveToPoint:la4 controlPoint:_arrowMid];

    [path addLineToPoint:q4s];   [path addQuadCurveToPoint:q4e controlPoint:p4];
 
    [path closePath];
    
    [[UIColor colorWithWhite:0 alpha:.62] setFill];
    [[UIColor colorWithWhite:1 alpha:.62] setStroke];
    [path fill];
    [path stroke];
    
    maskLayer.strokeColor = [[UIColor whiteColor] CGColor];
    maskLayer.fillColor = [[UIColor darkGrayColor] CGColor];
    maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
    maskLayer.path = [path CGPath];
    
    //Don't add masks to layers already in the hierarchy!
    UIView* superview = [self superview];
    [self removeFromSuperview];
    self.layer.mask = maskLayer;
    [superview addSubview:self];
}

@end

