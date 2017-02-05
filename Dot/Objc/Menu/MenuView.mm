
#import "MenuView.h"
#import "QuartzCore/CALayer.h"
#import "OrienteDevice.h"

#define PrintSizeView(...)  //DebugPrint(__VA_ARGS__)

@implementation MenuView

- (void)addBlur {
    
    UIVisualEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView* blurView = [UIVisualEffectView.alloc initWithEffect:blurEffect];
    blurView.frame = self.bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:blurView atIndex:0];
}

- (id)initWithFrame:(CGRect)frame_ blur:(bool)blur {
    
    self = [super initWithFrame:frame_];
    self.backgroundColor = [UIColor clearColor];
    if (blur) {
        [self addBlur];
    }
    _menuSize = frame_.size;
    _imageView = nil;
    _scaled = 1;
    _scale = 1; //TODO: self.scale has a nasty side effect in non portrait orientation
    self.hidden = NO;
    [self.layer setMinificationFilter:kCAFilterLinear];
    [self.layer setMagnificationFilter:kCAFilterLinear];

    return self;
}

- (id)initWithImage:(UIImage*)image blur:(bool)blur {
    
    CGImageRef imageRef = [image CGImage];
    _menuSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect frame = CGRectMake(0, 0, _menuSize.width, _menuSize.height);
    self = [self initWithFrame:frame blur:blur];
    _imageView = [UIImageView.alloc initWithImage:image];
    [self addSubview: _imageView];
    
    self.layer.cornerRadius = _menuSize.width/2;
    self.layer.masksToBounds= YES;

    _scaled = 0.25;
    self.scale = 1;
    self.hidden = NO;
    return self;
}

- (void)reorientCenter {
    
    float radians = [OrienteDevice shared].deviceRadians;
    [self setTransform:CGAffineTransformScale(CGAffineTransformRotate(CGAffineTransformIdentity,radians), _scale, _scale)];
}
- (void)setOnlyScale:(Float32)scale_ {
    _scale = _scaled * scale_;
    _radius =  _menuSize.width*_scale/2;

}
- (void)setScale:(CGFloat)scale_ {
    
    _scale = _scaled * scale_;
    _radius =  _menuSize.width*_scale/2;
     [self reorientCenter]; ////????
}

- (float)radiusForScale:(float) scale {
    
    float sizeScale = _scaled*scale;
    float radius = (_menuSize.width*sizeScale)/2;
    return radius;
}
- (bool)contains:(CGPoint)point_ {
    
    // x,y coordinates for _menuPulse center is (_radius, _radius)
    CGPoint delta = CGPointMake(point_.x-_radius, point_.y-_radius);
    float radius = sqrt(delta.x*delta.x + delta.y*delta.y);
    
    if (round(radius)>_radius)
        return false;
    else
        return true;
}


@end
