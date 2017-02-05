#import "main.h"
#import "UIExtras.h"
#import <QuartzCore/QuartzCore.h>
#import "OrienteDevice.h"
#import "SkyDefs.h"

@implementation UIScreen (Extras)


+ (UIDeviceOrientation)currentDeviceOrientation {
    
    
    // starting up device laying faceup yields two messages:
    // 1) UIDeviceOrientationPortrait, for unknown reason
    // 2) UIDeviceOrientationFaceUp, for correct orientation
    // so, keep track of last portrait or landscape orientation to determine button placement
    
    static UIDeviceOrientation lastOrientation = UIDeviceOrientationPortrait;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationFaceUp || 
        orientation == UIDeviceOrientationFaceDown || 
        orientation == UIDeviceOrientationUnknown) {
        orientation = lastOrientation;
    }
    else {
        lastOrientation = orientation;
    }
    return orientation;
}

+ (CGAffineTransform)transformForOrientation {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if        (orientation == UIInterfaceOrientationLandscapeLeft)      { return CGAffineTransformMakeRotation(M_PI*1.5);   }
    else if   (orientation == UIInterfaceOrientationLandscapeRight)     { return CGAffineTransformMakeRotation(M_PI/2);     }
    else if   (orientation == UIInterfaceOrientationPortraitUpsideDown) { return CGAffineTransformMakeRotation(-M_PI);      }
    else                                                                { return CGAffineTransformIdentity;                 }
}
@end

UIImage* rotate(UIImage* src, UIInterfaceOrientation orientation, bool mirror) {
    
    CGSize size;
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        size = CGSizeMake(src.size.height,src.size.width);
    }
    else {
        
        size = src.size;
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context(UIGraphicsGetCurrentContext());
    
    if (mirror) {
        
        CGContextTranslateCTM(context, size.width,0.); 
        CGContextScaleCTM(context, -1.0, 1.0);
    }
    
    if (orientation == UIInterfaceOrientationPortrait) {
        
        CGContextRotateCTM (context,  M_PI/2);
        CGContextTranslateCTM (context, 0, -size.width);
    } 
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown ) {
        
        CGContextRotateCTM (context, - M_PI/2);
        CGContextTranslateCTM (context, -size.width, 0);
    } 
    else if (orientation == UIInterfaceOrientationLandscapeRight ) {
        // NOTHING
    } 
    else if (orientation == UIInterfaceOrientationLandscapeLeft ) {
        
        CGContextRotateCTM (context, M_PI);
        CGContextTranslateCTM (context, -size.width,-size.height);
    }
    [src drawAtPoint:CGPointMake(0, 0)];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

@implementation UIImage (Extras)

+ (UIImage*) getIconPath:(const char*)path name:(const char*)name {
    
    NSString* pathStr = [NSString stringWithUTF8String:path];
    NSString* iconStr = [NSString stringWithUTF8String:name];
    
    UIImage* img = [UIImage imageNamed:iconStr];
    if (!img) {
        NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString* iconDir = [docPath stringByAppendingPathComponent:pathStr];
        NSString* iconPath = [iconDir stringByAppendingPathComponent:iconStr];
        NSData *data = [NSData dataWithContentsOfFile:iconPath];
        img = [UIImage imageWithData:data];
    }
    if (!img) {
        img = [UIImage imageNamed:@"dot.ring.white.png"];
    }
    return img;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSData*)dataFromImageScaledToSizeWithSameAspectRatio:(CGSize)destSize {
    
    CGSize sourceSize = self.size;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = destSize.width;
    CGFloat scaledHeight = destSize.height;
    CGPoint centerPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(sourceSize, destSize) == NO) {
        
        CGFloat widthFactor  = destSize.width  / sourceSize.width;
        CGFloat heightFactor = destSize.height / sourceSize.height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = sourceSize.width * scaleFactor;
        scaledHeight = sourceSize.height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            centerPoint.y = (destSize.height - scaledHeight) * 0.5; 
        }
        else if (widthFactor < heightFactor) {
            centerPoint.x = (destSize.width - scaledWidth) * 0.5;
        }
    }     
    
    CGImageRef imageRef = [self CGImage];
    CGContextRef context;
    int depth = 4;    
    int bufSize = depth * destSize.width * destSize.height;
    void *imageData = malloc(bufSize);
    
    if (self.imageOrientation == UIImageOrientationUp || 
        self.imageOrientation == UIImageOrientationDown) {
        
        context = CGBitmapContextCreate(imageData,
                                       destSize.width,
                                       destSize.height,
                                       CGImageGetBitsPerComponent(imageRef),
                                       depth*destSize.width,
                                       CGImageGetColorSpace(imageRef),
                                       CGImageGetBitmapInfo(imageRef)); 
    } 
    else {
        
        context = CGBitmapContextCreate(imageData,
                                       destSize.height,
                                       destSize.width,
                                       CGImageGetBitsPerComponent(imageRef),
                                       depth*destSize.height,
                                       CGImageGetColorSpace(imageRef),
                                       CGImageGetBitmapInfo(imageRef)); 
        
        // switch scaledWidth,scaledHeight and centerPoint
        centerPoint = CGPointMake(centerPoint.y, centerPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
    }   
    if (self.imageOrientation == UIImageOrientationLeft) {
        
        CGContextRotateCTM (context, M_PI/2);
        CGContextTranslateCTM (context, 0, -destSize.height);
        
    } else if (self.imageOrientation == UIImageOrientationRight) {
        
        CGContextRotateCTM (context, -M_PI/2);
        CGContextTranslateCTM (context, -destSize.width, 0);
        
    } else if (self.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (self.imageOrientation == UIImageOrientationDown) {
        
        CGContextTranslateCTM (context, destSize.width, destSize.height);
        CGContextRotateCTM (context, M_PI);
    }
    
    CGContextDrawImage(context, CGRectMake(centerPoint.x, centerPoint.y, scaledWidth, scaledHeight), imageRef);
    CGContextRelease(context);
    
    return [NSData dataWithBytesNoCopy:imageData length:bufSize freeWhenDone:YES];
}

- (NSData*)dataFromImageScaledToSize:(CGSize)destSize {
    
    int depth = 4;    
    int bufSize = depth * destSize.width * destSize.height;
    void *imageData = malloc(bufSize);
    
    CGImageRef imageRef = [self CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef context;
    
    if (self.imageOrientation == UIImageOrientationUp || 
        self.imageOrientation == UIImageOrientationDown) {
        
        context = CGBitmapContextCreate(imageData,
                                       destSize.width,
                                       destSize.height,
                                       CGImageGetBitsPerComponent(imageRef),
                                       depth*destSize.width,
                                       CGImageGetColorSpace(imageRef),
                                       CGImageGetBitmapInfo(imageRef)); 
    } 
    else {
        
        context = CGBitmapContextCreate(imageData,
                                       destSize.height,
                                       destSize.width,
                                       CGImageGetBitsPerComponent(imageRef),
                                       depth*destSize.height,
                                       CGImageGetColorSpace(imageRef),
                                       CGImageGetBitmapInfo(imageRef)); 
    }   
    
    if (self.imageOrientation == UIImageOrientationLeft) {
        
        CGContextRotateCTM (context, M_PI/2);
        CGContextTranslateCTM (context, 0, -destSize.height);
        
    } else if (self.imageOrientation == UIImageOrientationRight) {
        
        CGContextRotateCTM (context, -M_PI/2);
        CGContextTranslateCTM (context, -destSize.width, 0);
        
    } else if (self.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (self.imageOrientation == UIImageOrientationDown) {
        
        CGContextTranslateCTM (context, destSize.width, destSize.height);
        CGContextRotateCTM (context, M_PI);
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, destSize.width, destSize.height), imageRef);
    CGContextRelease(context);
    
    return [NSData dataWithBytesNoCopy:imageData length:bufSize freeWhenDone:YES];
}

- (void)shrinkFromLocation:(CGPoint)fromLocation  underView:(UIView*)underView {
    
     if (fromLocation.x==0 && fromLocation.y==0) 
         return;
    
    UIImageView *imageView = [UIImageView.alloc initWithImage:self];
    CGFloat scale = underView.frame.size.width / self.size.width;

    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    imageView.center = fromLocation;
    CGAffineTransform orientationTransform = [UIScreen transformForOrientation];
    imageView.transform = CGAffineTransformScale(orientationTransform, .5, .5);  
    [win addSubview:imageView];
    [UIView animateWithDuration:.33 delay:0. options:AnimUserContinue
                     animations:^{ 
                         imageView.transform = CGAffineTransformScale(orientationTransform, 1, 1); 
                     } 
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:.3 delay:0. options:AnimUserContinue
                                          animations:^{ 
                                              imageView.center = underView.center;
                                              imageView.transform = CGAffineTransformScale(orientationTransform, scale, scale);
                                          } 
                                          completion:^(BOOL finished){
                                              
                                              [imageView removeFromSuperview];        
                                          }];
                     }];
}

- (UIImage*)imageAddImage:(UIImage*)image under:(bool)under {
    
    CGImageRef  selfRef  = [self CGImage];
    CGRect      selfRect = CGRectMake(0,0,CGImageGetWidth(selfRef),CGImageGetHeight(selfRef));
    CGImageRef  addRef   = [image CGImage];
    CGRect      addRect  = CGRectMake(0,0,CGImageGetWidth(addRef),CGImageGetHeight(addRef));
    addRect.origin.x = (selfRect.size.width-addRect.size.width)/2;
    addRect.origin.y = (selfRect.size.height-addRect.size.height)/2;
    
    UIGraphicsBeginImageContext(selfRect.size); // this will crop
    if (under) {
        
        [image drawInRect:addRect];
        [self drawInRect:selfRect];
    }
    else {
        
        [self drawInRect:selfRect];
        [image drawInRect:addRect];
    }
    
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageAddLowerLeftImage:(UIImage*)image {
    
    CGImageRef  selfRef  = [self CGImage];
    CGRect      selfRect = CGRectMake(0,0,CGImageGetWidth(selfRef),CGImageGetHeight(selfRef));
    CGImageRef  addRef   = [image CGImage];
    CGRect      addRect  = CGRectMake(0,0,CGImageGetWidth(addRef),CGImageGetHeight(addRef));
    addRect.origin.x = 0;
    addRect.origin.y = selfRect.size.height-addRect.size.height;
    
    UIGraphicsBeginImageContext(selfRect.size); // this will crop

        [self drawInRect:selfRect];
        [image drawInRect:addRect];
    
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageAddBelowImage:(UIImage*)image withBorder:(bool)withBorder {
    
    CGImageRef selfRef   = [self CGImage];
    CGRect     selfRect  = CGRectMake(0,0,CGImageGetWidth(selfRef),CGImageGetHeight(selfRef));
    CGImageRef addRef    = [image CGImage];
    CGRect     addRect   = CGRectMake(0,selfRect.size.height,CGImageGetWidth(addRef),CGImageGetHeight(addRef));
    CGSize     totalSize = CGSizeMake(selfRect.size.width,selfRect.size.height + addRect.size.height);
    
    UIGraphicsBeginImageContext(totalSize);
    
    [self drawInRect:selfRect];
    [image drawInRect:addRect];
    
    if (withBorder) {
        
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        addRect.origin.y = addRect.origin.y-1;
        CGContextSetRGBStrokeColor(contextRef, 0, 0, 0, 1);
        CGContextStrokeRectWithWidth(contextRef, addRect,2);
    }
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageWithRoundedCornersForSize:(CGSize)targetSize {
 
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect targetRect = CGRectMake(0, 0, targetSize.width, targetSize.height);
    [[UIBezierPath bezierPathWithRoundedRect:targetRect cornerRadius:targetSize.height/2] addClip];
	[self drawInRect:targetRect];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageWithRoundedCornersForSize:(CGSize)targetSize color:(UIColor*)color {
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect targetRect = CGRectMake(0, 0, targetSize.width, targetSize.height);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, targetRect);
    
    [[UIBezierPath bezierPathWithRoundedRect:targetRect cornerRadius:targetSize.height/2] addClip];
    
	[self drawInRect:targetRect];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize {
    
	UIImage *sourceImage = self;
	UIImage *newImage = nil;        
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;
		
		if (widthFactor > heightFactor) 
			scaleFactor = widthFactor; // scale to fit height
		else
			scaleFactor = heightFactor; // scale to fit width
		scaledWidth  = width * scaleFactor;
		scaledHeight = height * scaleFactor;
		
		// center the image
		if (widthFactor > heightFactor) {
            
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
		}
		else if (widthFactor < heightFactor) {
            
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }       
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) 
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    
    return [newImage imageWithRoundedCornersForSize:targetSize];
}

+ (UIImage*)screenshot {

    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = UIScreen.mainScreen.fixedCoordinateSpace.bounds.size;
    if (UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) 
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
