#import "MuImagePicker.h"
#import "AppDelegate.h"
#import "OrienteDevice.h"

@implementation MuImagePicker

- (id)initWithViewController:(UIViewController*)controller_
                  completion:(CompletionDict)completion_
{
    
    self = [super init];
     self.view.transform = OrienteDevice.shared.transform;
    _controller = controller_;
    _popover = 0;
    return self;
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

- (bool)startPicker:(UIImagePickerControllerSourceType)pickerType allowsEditing:(BOOL)allowsEditing frame:(CGRect)frame {
    
    UIImagePickerController* picker= [UIImagePickerController.alloc init]; 
    
    if ([UIImagePickerController isSourceTypeAvailable:pickerType]) {
        
        picker.sourceType = pickerType;
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
    
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else {
    
        if (_completion) {
            _completion(@{@"result":@"cancel"});
        }
    }
    
    picker.delegate = self;
    picker.allowsEditing = allowsEditing;    
    
    if (UIDevice.currentDevice.userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        
        self.popover = [UIPopoverController.alloc initWithContentViewController:picker];        
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:frame inView:_controller.view  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [_controller presentModalViewController:picker animated:YES];
    }
    return YES;
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
        
    picker.delegate = nil;
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        self.popover.delegate = nil;
        [self.popover dismissPopoverAnimated:YES];
        self.popover = 0;
    }
    else {
        [_controller dismissModalViewControllerAnimated:YES];
    }
    if (_completion) {
        _completion(info);
    }

}

- (void)imagePickerControllerCancelled {

    [_controller dismissModalViewControllerAnimated:YES];
    if (_completion) {
        _completion(@{@"result":@"cancel"});
    }
  }

- (void)popoverControllerDidDismissPopover:(UIPopoverController*)popoverController {
    
    _popover.delegate = nil;
     _popover = nil;
    if (_completion) {
        _completion(@{@"result":@"cancel"});
    }
}

- (void)cancelFromDoubleTap {
 
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        [self.popover dismissPopoverAnimated:NO];
        self.popover = 0;
    }
    else {
        [_controller dismissModalViewControllerAnimated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


@end
