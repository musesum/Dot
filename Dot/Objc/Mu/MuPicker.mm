#import "MuPicker.h"
#import "UIExtras.h"
#import "MenuDock.h"
#import "AppDelegate.h"
#import "OrienteDevice.h"
#import "AppDelegate.h"
#import "ScreenVC.h"
#import "MuNavigationC.h"



#define LogMuPicker(...) DebugLog(__VA_ARGS__)

@implementation MuPicker

- (id)initWithParentVC:(UIViewController*)parentVC_
             contentVC:(UIViewController*)contentVC_ {
    
    self = [super init];
    _parentVC = parentVC_;
    _contentVC = contentVC_;
    _contentVC.modalPresentationStyle = UIModalPresentationPopover;
    return self;
}

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}

- (void)startPickerAnchor:(CGRect)anchor {
    
    UIPopoverArrowDirection direction;
    switch (OrienteDevice.shared.interface) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:           direction = UIPopoverArrowDirectionRight;  break;
        case UIInterfaceOrientationLandscapeLeft:      direction = UIPopoverArrowDirectionDown;   break;
        case UIInterfaceOrientationPortraitUpsideDown: direction = UIPopoverArrowDirectionLeft;   break;
        case UIInterfaceOrientationLandscapeRight:     direction = UIPopoverArrowDirectionUp;     break;
    }
    [self startPickerAnchor:anchor fromDirection:direction];
}

- (void)startPickerAnchor:(CGRect)anchor fromDirection:(UIPopoverArrowDirection)direction {
    
    UINavigationController *destNav = [MuNavOrientedC.alloc initWithRootViewController:_contentVC];
    destNav.navigationBarHidden = YES;
    destNav.modalPresentationStyle = UIModalPresentationPopover;
    
    _contentVC.preferredContentSize = CGSizeMake(320,320);
    _popover = destNav.popoverPresentationController;
    _popover.delegate = self;
    _popover.sourceView = _parentVC.view;
    _popover.sourceRect = anchor;
    _popover.permittedArrowDirections = UIPopoverArrowDirectionDown;
    _popover.backgroundColor = [UIColor colorWithWhite:.2 alpha:1];
    
    [_parentVC presentViewController:destNav animated:YES completion:nil];
}

- (void)startPickerView:(UIView*)view {
    
    CGFloat x = view.frame.origin.x;
    CGFloat y = view.frame.origin.y;
    CGFloat h = view.frame.size.height;
    CGFloat w = view.frame.size.width;
    CGPoint from;
    
    switch (OrienteDevice.shared.interface) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:           from = CGPointMake(w/2, 0); break;
        case UIInterfaceOrientationPortraitUpsideDown: from = CGPointMake(w/2, h); break;
        case UIInterfaceOrientationLandscapeLeft:      from = CGPointMake(w, h/2); break;
        case UIInterfaceOrientationLandscapeRight:     from = CGPointMake(0, h/2); break;
    }
    CGPoint center = [view convertPoint:from toView:nil];
    CGRect anchor = CGRectMake(center.x, center.y,0,0);
    [self startPickerAnchor:anchor];
}


@end

