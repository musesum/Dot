#import "main.h"
#import "MuNavigationC.h"

@implementation MuNavOrientedC

- (BOOL)shouldAutorotate {
    
    return NO;
}
-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
    
    switch (UIDevice.currentDevice.orientation) {
            
            
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortrait:
            
            return UIInterfaceOrientationMaskPortrait;
            
        case UIDeviceOrientationPortraitUpsideDown:
            
            return UIInterfaceOrientationMaskPortraitUpsideDown;
            
        case UIDeviceOrientationLandscapeLeft:
            
            return UIInterfaceOrientationMaskLandscapeLeft;
            
        case UIDeviceOrientationLandscapeRight:
            
            return UIInterfaceOrientationMaskLandscapeRight;
    }
}
@end

@implementation MuNavigationC

- (BOOL)shouldAutorotate {
    
    return NO;
}
-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {

    return UIInterfaceOrientationMaskPortrait;
}
@end
