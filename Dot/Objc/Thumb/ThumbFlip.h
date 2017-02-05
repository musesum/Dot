#import "main.h"

@interface ThumbFlip : UIView {
    
    UIImageView* _back;
    UIImageView* _front;
    bool _flipped; // current state of back and front visible
    bool _twisted; // use twisting animation
    bool _animating; // animating a twist state
}

- (id)initWithFrame:(CGRect)frame_
               back:(UIImage*)back_
              front:(UIImage*)front_;

- (void)setFlipped:(bool)flipped;
- (void)makeTwisted;

@end

