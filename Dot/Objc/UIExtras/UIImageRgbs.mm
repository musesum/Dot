
#import "UIImageRgbs.h"

#import "ColorRGBA.h"
#import "Colors.h"

@implementation UIImageRgbs

+ (UIImage *)imageFromBuf:(char*)buf size:(CGSize)size {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(buf, size.width, size.height,
                                                       8, 4*size.width, // bytesPerRow
                                                       colorSpace, kCGImageAlphaNoneSkipLast);         
    CFRelease(colorSpace);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    CFRelease(bitmapContext);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    return image;
}

+ (char*)bufFromRgbs:(Rgbs*)rgbs size:(CGSize)size {
    
    Rgb *rgbp = rgbs->_rgbArray;
    int rgbSize = rgbs->_rgbNow;
    
    Rgb rgb;
    Colors colors;
    int bufsize = size.width*size.height*4;
    char* buf = (char*)malloc(bufsize);
    
    if (rgbp==nil)
        return buf;
    
    for (int x = 0; x<size.width; x++) {
        
        int rgbi = x*rgbSize/size.width;
        rgb = rgbp[rgbi];
        
        for (int y = 0; y<size.height; y++) {
            
            int ofs = (y*size.width + x) *4;
            
            buf[ofs+0] = rgb.r;
            buf[ofs+1] = rgb.g;
            buf[ofs+2] = rgb.b;
            buf[ofs+3] = 0;
        }
    }
    return buf;
}

+ (UIImageView *)imageViewFromRgbs:(Rgbs*)rgbs size:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIImageView*imageView =  [UIImageView.alloc initWithFrame:rect];
    imageView.image = [self imageFromRgbs:rgbs size:size];
    return imageView;
}

+ (UIImage *)imageFromRgbs:(Rgbs*)rgbs size:(CGSize)size {
    
    char *buf      = [self bufFromRgbs:rgbs size:size];
    UIImage* image = [self imageFromBuf:buf size:size];
    free (buf);
    return image;
}

+ (char*)testBufFromSize:(CGSize)size {
    
    Hsv hsv;
    Rgb rgb;
    Colors colors;
    int bufsize = size.width*size.height*4;
    char* buf = (char*)malloc(bufsize);
    for (int x = 0; x<size.width; x++) {
        
        for (int y = 0; y<size.height; y++) {
            
            int ofs = (y*size.width + x) *4;
            hsv.h = x*360/256;
            hsv.s = 100;
            hsv.v = 100;
            rgb = colors.hsv2rgb(hsv);
            buf[ofs+0] = rgb.r;
            buf[ofs+1] = rgb.g;
            buf[ofs+2] = rgb.b;
            buf[ofs+3] = 0;
        }
    }
    return buf;
}

@end
