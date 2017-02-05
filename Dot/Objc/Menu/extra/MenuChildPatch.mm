
#import "MenuChildPatch.h"
#import "AppDelegate.h"
#import "MuPatchPicker.h"
#import "MuPicker.h"
#import "MenuParent.h"
#import "MenuParent+dragging.h"
#import "MenuDock+Reveal.h"
#import "MenuDock+Add.h"
#import "SkyMain.h"
#import "ScreenVC.h"

@implementation MenuChildPatch

- (void)pickerPatchCleanup {
    
    _pinned = NO;
    ScreenVC* svc = ScreenVC.shared;
    [_app.window bringSubviewToFront:svc.view];
    _patchPicker = nil;
}

#pragma mark - MenuParentDelegate

- (void)MenuParentSingleTap {
    
    _pinned = YES;
    
    MenuDock * menuDock = MenuDock.shared;
    
    [menuDock shrinkDock];
    
    _patchPicker = [MuPatchPicker.alloc initWithCompletion:^(NSDictionary*d) {
        
        NSString* path = [d objectForKey:@"path"];
        MenuDock * menuDock = MenuDock.shared;
        
        if (path) {
            NSString* name = [path lastPathComponent];
            NSString* patchName = [name stringByReplacingOccurrencesOfString:@".muse" withString:@""];
            
            for (MenuParent* parent in menuDock.parents) {
                if ([patchName isEqualToString:parent.patchName]) {
                    
                    [parent removeFromDock];
                    break;
                }
            }
            [menuDock addPatchName:patchName fromLocation:_patchPicker.clickedLocation];
        }
        [self pickerPatchCleanup];
    }];
    
    _muPicker = [MuPicker.alloc initWithParentVC:ScreenVC.shared contentVC:_patchPicker];
    [_muPicker startPickerAnchor:CGRectMake(menuDock.cursorCenter.x,
                                            menuDock.cursorCenter.y - menuDock.frame.size.height/2,1,1)];
    
}

- (void)MenuParentDoubleTap {
 
    //don't clear background
}

- (void)MenuParentDraggedOut {
    
}

@end




