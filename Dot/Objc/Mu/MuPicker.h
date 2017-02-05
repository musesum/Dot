
#import <UIKit/UIKit.h>
#import "Completion.h"

@interface MuPicker : NSObject <UIPopoverPresentationControllerDelegate> {
	
    UIViewController* _parentVC;
    UIViewController* _contentVC;
    UIPopoverPresentationController* _popover;
}

- (id)initWithParentVC:(UIViewController*)parentVC_
             contentVC:(UIViewController*)contentVC_;

- (void)startPickerAnchor:(CGRect)anchor;
- (void)startPickerAnchor:(CGRect)anchor fromDirection:(UIPopoverArrowDirection)direction;
- (void)startPickerView:(UIView*)view;
@end

