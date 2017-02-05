
#import "MenuChildInfo.h"
#import "MuInfoPicker.h"
#import "AppDelegate.h"
#import "MenuDock+Reveal.h"
#import "ScreenVC.h"

@implementation MenuChildInfo

- (void)MenuParentSingleTap {
    
    MenuDock * menuDock = MenuDock.shared;
    
    [MenuDock.shared shrinkDock];
    
    _infoPicker = [MuInfoPicker.alloc initWithCompletion:^(NSDictionary*d) {
        _infoPicker = nil;
        _pinned = NO;
        
    }];
    
    _muPicker = [MuPicker.alloc initWithParentVC:ScreenVC.shared contentVC:_infoPicker];
    [_muPicker startPickerAnchor:CGRectMake(menuDock.cursorCenter.x,
                                            menuDock.cursorCenter.y - menuDock.frame.size.height/2,1,1)];
}

@end




