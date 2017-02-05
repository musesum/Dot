#import "main.h"

@interface UIScreen (Extras)

+ (UIDeviceOrientation)currentDeviceOrientation;
+ (CGAffineTransform)transformForOrientation;
@end

UIImage* rotate(UIImage* src, UIInterfaceOrientation orientation, bool mirror);

@interface UIImage (Extras)
+ (UIImage*) getIconPath:(const char*)path name:(const char*)name;
+ (UIImage*)screenshot;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (NSData*)dataFromImageScaledToSizeWithSameAspectRatio:(CGSize)destSize;

- (void)shrinkFromLocation:(CGPoint)fromLocation underView:(UIView*)underView;
- (NSData*)dataFromImageScaledToSize:(CGSize)destSize;
- (UIImage*)imageAddImage:(UIImage*)image under:(bool)under;
- (UIImage*)imageWithRoundedCornersForSize:(CGSize)targetSize;
- (UIImage*)imageWithRoundedCornersForSize:(CGSize)targetSize color:(UIColor*)color;
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (UIImage*)imageAddLowerLeftImage:(UIImage*)image;
- (UIImage*)imageAddBelowImage:(UIImage*)image withBorder:(bool)withBorder;

@end

