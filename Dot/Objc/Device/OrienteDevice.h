#import "main.h"

@interface OrienteDevice : UIView {
    
    UIDeviceOrientation _orientation;
}

@property(nonatomic) UIInterfaceOrientation interface;
@property(nonatomic) float interfaceRadians;
@property(nonatomic) float deviceRadians;

+ (OrienteDevice*)shared;
- (CGAffineTransform)transform;
- (void)orientationChanged:(NSNotification*)notification;
@end
