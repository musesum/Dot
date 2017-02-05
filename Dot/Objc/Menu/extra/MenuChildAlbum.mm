
#import "MenuChildAlbum.h"
#import "MuImagePicker.h"
#import "MenuDock+Reveal.h"
#import "ScreenVC.h"

@implementation MenuChildAlbum

@synthesize imagePicker;
@synthesize doubleTapping;


- (id)initWithPatch:(SkyPatch*)patch {
    self = [super init];
    _imagePickerReleaseTimer = nil;
    return self;
}


- (void)MenuParentSingleTap {
    
    _pinned = YES;
    
    if (self.imagePicker) {
        
        [_imagePickerReleaseTimer invalidate];
    }
    MenuDock *md = MenuDock.shared;
    [md shrinkDock];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.imagePicker = [MuImagePicker.alloc initWithViewController:ScreenVC.shared completion:^(NSDictionary*d) {
        
        //UIImage* image = [info objectForKey:  UIImagePickerControllerEditedImage];
        NSValue* value = [d objectForKey: UIImagePickerControllerCropRect];
        if (value ) {
            CGRect rect;
            [value getValue:&rect];
            //ss[_skyMain advanceWithImage:image rect:rect imageType:kImageFromAlbum];
        }
        self.imagePicker = 0;
        _pinned = NO;
    }];
    CGRect frame = CGRectMake(md.center.x, md.center.y - md.frame.size.height/2,1,1);
    
    if (![imagePicker startPicker:UIImagePickerControllerSourceTypePhotoLibrary  allowsEditing:YES  frame:frame]) {
        
        self.imagePicker = 0;
        _pinned = NO;
    }
}

@end




