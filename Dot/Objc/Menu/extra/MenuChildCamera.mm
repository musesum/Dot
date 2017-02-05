#import "MenuChildCamera.h"
#import "MuImagePicker.h"
#import "MenuDock.h"
#import "ScreenVC.h"
#import "SkyMain.h"
#import "SkyMain+Patch.h"
#import "SkyPatch.h"

@implementation MenuChildCamera


- (id)initWithPatch:(SkyPatch*)patch_ {
    
    self = [super init];
    _imagePickerReleaseTimer = nil;
    return self;
}

#pragma mark - Menu Parent Dock

- (void)MenuParentDoubleTap {
    
    self.doubleTapping = YES;
    [self performSelector:@selector(pickerClearDoubleTap) withObject:nil afterDelay:.5];
    
    [self.imagePicker imagePickerControllerCancelled];
    [SkyMain.shared readImageFromType:kImageFromCamera];
}

- (void)MenuParentSingleTap {
    
    _pinned = YES;
    
    if (self.imagePicker) {
        
        [_imagePickerReleaseTimer invalidate];
    }
    else {

        self.imagePicker = [MuImagePicker.alloc initWithViewController:ScreenVC.shared completion:^(NSDictionary *d) {
                                //prl UIImage* image = [info objectForKey: UIImagePickerControllerEditedImage];
                                NSValue* value = [d objectForKey: UIImagePickerControllerCropRect];
                                if (value) {
                                    CGRect rect;
                                    [value getValue:&rect];
                                    
                                    //prl [_skyMain advanceWithImage:image rect:rect imageType:kImageFromCamera];
                                    UIImageWriteToSavedPhotosAlbum([d objectForKey: UIImagePickerControllerOriginalImage], nil, nil, nil);
                                }
                                _pinned = NO;
                            }];
    }
    [self performSelector:@selector(pickerCameraContinue) withObject:nil afterDelay:RelocationInterval];
}

- (void)pickerCameraContinue {
    
    if (self.doubleTapping) {
        return;
    }
    MenuDock * md = MenuDock.shared;
    CGRect frame = CGRectMake(md.center.x, md.center.y - md.frame.size.height/2,1,1);
    
    if (![_imagePicker startPicker:UIImagePickerControllerSourceTypeCamera allowsEditing:YES frame:frame]) {
        _imagePicker = nil;
        _pinned = NO;
    }
}

@end




