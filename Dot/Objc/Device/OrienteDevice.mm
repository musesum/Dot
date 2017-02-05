#import "OrienteDevice.h"

//TODO these were pulled from a delegate - put them back?
#import "MenuDock.h"
#import "SkyMain.h"

#define PrintOrienteDevice(...)  //DebugPrint(__VA_ARGS__)

@implementation OrienteDevice

+ (OrienteDevice*) shared {
    
    
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [self.alloc init];
    });
    return shared;
}

- (CGAffineTransform)transform {
    
    return CGAffineTransformScale(CGAffineTransformRotate(CGAffineTransformIdentity,-_interfaceRadians), 1, 1);
}

- (id)init {
    
    self = [super init];
    
    _interfaceRadians = 0;
    _deviceRadians    = 0;
    _interface = UIInterfaceOrientationPortrait;
    _orientation = UIDeviceOrientationPortrait;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    return self;
}


- (void)orientationChanged:(NSNotification*)notification {
    
    _interface = UIApplication.sharedApplication.statusBarOrientation;
    
    UIDeviceOrientation oldOrientation = _orientation;
    _orientation =  UIDevice.currentDevice.orientation;
    
    if (oldOrientation != _orientation) {
        
        UIInterfaceOrientation oldInterface = _interface;
        
        switch (_orientation) {

            case UIDeviceOrientationPortrait:               _interface = UIInterfaceOrientationPortrait; break;
            case UIDeviceOrientationLandscapeLeft:          _interface = UIInterfaceOrientationLandscapeRight; break;
            case UIDeviceOrientationPortraitUpsideDown:     _interface = UIInterfaceOrientationPortraitUpsideDown; break;
            case UIDeviceOrientationLandscapeRight:         _interface = UIInterfaceOrientationLandscapeLeft; break;
                
            default:  break;
        }
        if (oldInterface != _interface) {
            
            [[UIApplication sharedApplication] setStatusBarOrientation:_interface];

        }
    }
    
    switch (_orientation) {
            
        case UIDeviceOrientationPortrait:               _deviceRadians = 0*M_PI/2; break;
        case UIDeviceOrientationLandscapeLeft:          _deviceRadians = 1*M_PI/2; break;
        case UIDeviceOrientationPortraitUpsideDown:     _deviceRadians = 2*M_PI/2; break;
        case UIDeviceOrientationLandscapeRight:         _deviceRadians = 3*M_PI/2; break;
            
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        default:                           /* ignore these */ break;
    }
    
    switch (_interface) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:               _interfaceRadians = 0*M_PI/2; break;
        case UIInterfaceOrientationLandscapeLeft:          _interfaceRadians = 1*M_PI/2; break;
        case UIInterfaceOrientationPortraitUpsideDown:     _interfaceRadians = 2*M_PI/2; break;
        case UIInterfaceOrientationLandscapeRight:         _interfaceRadians = 3*M_PI/2; break;
            
    }
    switch (_interface) {
            
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:               PrintOrienteDevice(" •^%.f ",_interfaceRadians); break;
        case UIInterfaceOrientationLandscapeLeft:          PrintOrienteDevice(" •<%.f ",_interfaceRadians); break;
        case UIInterfaceOrientationPortraitUpsideDown:     PrintOrienteDevice(" •v%.f ",_interfaceRadians); break;
        case UIInterfaceOrientationLandscapeRight:         PrintOrienteDevice(" •>%.f ",_interfaceRadians); break;
        default:                                           PrintOrienteDevice(" •?%.f ",_interfaceRadians); break;
    }
    //TODO these were pulled from a delegate - put somewhere?
    [MenuDock.shared resetOrientation];
    [SkyMain.shared setNeedsUpdate:YES];
}

@end
