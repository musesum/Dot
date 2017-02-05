#import "Completion.h"

@interface ScrubView : UIView {
    
    CGSize _size;
    CGPoint _startPoint;
    CGPoint _movePoint;
    CGPoint _deltaPoint;
    CompletionVoid _update;
    CompletionVoid _reset;
    
}
@property (nonatomic) CGPoint deltaPoint;
@property (nonatomic,strong) UIImageView *imageView;

- (id)initWithFrame:(CGRect)frame_
              image:(UIImage*)image_
             update:(CompletionVoid)update_
              reset:(CompletionVoid)reset_;

- (void)setCursor;
@end
