#import "main.h"
#import "MuDrawDot.h"

@implementation MuDrawDot

@synthesize radius = _radius;
@synthesize color = _color;

- (id)initWithFrame:(CGRect)frame_ {
    
    self = [super initWithFrame:frame_];
    _radius=0;
    self.opaque = NO;
    self.userInteractionEnabled = YES;
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
#define BrushScale 2
    if (!_radius)
        return;
    CGFloat size = _radius * BrushScale;

    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    /*
    CGContextSetRGBFillColor(contextRef, .1, .1, .1, 1); // dark grey unfilled section
    CGContextFillEllipseInRect(contextRef, frame);
     */
    // Draw a circle (filled)
    CGContextSetRGBFillColor(contextRef, _color.red, _color.green, _color.blue, 1);
    CGPoint center = CGPointMake(frame.size.width/2, frame.size.height/2);
    CGRect fillFrame = CGRectMake(center.x-size, center.y-size, size*2, size*2);
    CGContextFillEllipseInRect(contextRef, fillFrame);
    
    // draw a border
    CGRect strokeFrame = CGRectMake(center.x-size-2, center.y-size-2, size*2+4, size*2+4);
    CGContextSetRGBStrokeColor(contextRef, 1, 1, 1, 1);
    CGContextSetLineWidth(contextRef,1);
    CGContextStrokeEllipseInRect(contextRef, strokeFrame);
}

@end
