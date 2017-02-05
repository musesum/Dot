
#import "ThumbFlip.h"
#import "SkyDefs.h" // for AnimUserContinue
#import "UIExtras.h"


@implementation ThumbFlip

- (id)initWithFrame:(CGRect)frame_
               back:(UIImage*)back_
              front:(UIImage*)front_ {
    
    self = [super initWithFrame:frame_];
 
    _animating = NO;
    _twisted = NO;
    _flipped = NO;
    
    if (!back_) {
        back_ = [UIImage getIconPath:"/tr3/dot/png" name:"dot.menu.back.png"];
    }
    _back  = [UIImageView.alloc initWithImage:back_];
    _front = [UIImageView.alloc initWithImage:front_];
    
    _back.frame = frame_;
    _front.frame = frame_;
    
    [self addSubview:_front];
    [self addSubview:_back];
    
    return self;
}

- (void) makeTwisted {
    
    _twisted = YES;
    
    if (_flipped)   { _front.alpha = 1; _back.alpha = 0; }
    else            { _front.alpha = 0; _back.alpha = 1; }
}

- (void) setFlipped:(bool)flipped_ {
    
    if (_flipped != flipped_) {
        
        _flipped = flipped_;
        
        if (_twisted) {
            
            [self animateTwist];
        }
        else  if (!_flipped) {
            
            [_back removeFromSuperview];
            [self addSubview:_back];
            
        } else {
            
            [_front removeFromSuperview];
            [self addSubview:_front];
        }
    }
}

#pragma mark - Flip Button

- (void) animateTwist {
    
    static CGAffineTransform transformNormal    = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
    static CGAffineTransform transformClockwise = CGAffineTransformRotate(CGAffineTransformIdentity, 0 + M_PI - .01);
    static CGAffineTransform transformCounter   = CGAffineTransformRotate(CGAffineTransformIdentity, 0 - M_PI + .01);

    if (_animating ) {
        
        CALayer *currentLayer = self.layer.presentationLayer;
        [self.layer removeAllAnimations];
        self.layer.transform = currentLayer.transform;
        self.layer.position = currentLayer.position;

    } else if (_flipped) {
        
        _back.transform  =  transformNormal;
        _front.transform =  transformCounter;
    }
    else {
        _front.transform =  transformNormal;
        _back.transform  =  transformCounter;
    }
    
    _animating = YES;
    
    [UIView animateWithDuration:1.0
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction |
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
        
        if (_flipped) {
            
            _back.transform =  transformClockwise;
            _front.transform = transformNormal;
            _back.alpha = 0;
            _front.alpha = 1;
        }
        else {
            
            _back.transform  =  transformNormal;
            _front.transform =  transformClockwise;
            _back.alpha = 1;
            _front.alpha = 0;
        }
    } completion:^(BOOL finished){
        if (finished) {
            _animating = NO;
        }
    }];
}


@end
