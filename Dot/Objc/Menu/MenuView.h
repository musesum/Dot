#import "main.h"

@class SkyPatch;

@interface MenuView : UIView {
    
    CGFloat _radius;
    CGFloat _scale;
    CGSize _menuSize;
    UIImageView* _imageView;
}

@property (nonatomic) CGFloat scaled;
@property (nonatomic) CGFloat scale;
@property (nonatomic,readonly) CGSize menuSize;
@property (nonatomic,strong)   UIImageView* imageView;

- (id)initWithFrame:(CGRect)frame_ blur:(bool)blur;
- (id)initWithImage:(UIImage*)image_ blur:(bool)blur;
- (void)reorientCenter;
- (float)radiusForScale:(float) scale;
- (bool)contains:(CGPoint)point_;
- (void)setOnlyScale:(Float32)scale_;
@end

