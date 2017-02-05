#import "Pals.h"
#import "Rgbs.h"

@interface UIImageRgbs : NSObject {

}
+ (UIImage *)imageFromBuf:(char*)buf size:(CGSize)size;
+ (char*)bufFromRgbs:(Rgbs*)rgbs size:(CGSize)size;
+ (UIImageView *)imageViewFromRgbs:(Rgbs*)rgbs size:(CGSize)size;
+ (UIImage *)imageFromRgbs:(Rgbs*)rgbs size:(CGSize)size;
+ (char*)testBufFromSize:(CGSize)size;

@end
