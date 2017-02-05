
#import "MuPicker.h"
#import "Completion.h"

@interface MuImagePicker : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate> { 
    
    UIViewController* _controller; // owned by parent
    CompletionDict _completion;
}
@property (strong) UIPopoverController* popover;    

- (id)initWithViewController:(UIViewController*)controller_
                  completion:(CompletionDict)completion_;

- (bool)startPicker:(UIImagePickerControllerSourceType)pickerType  
     allowsEditing:(BOOL)allowsEditing 
             frame:(CGRect)frame;

- (void)cancelFromDoubleTap;

- (void)imagePickerControllerCancelled;

@end
