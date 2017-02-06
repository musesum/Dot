#import "main.h"

@class SkyTr3;
@class SkyMain;
@class ScreenVC;
@class VideoManager;
@class SoundEffect;
@class MuNavigationC;
@class MenuDock;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    
    SkyTr3*         _skyTr3;
    SkyMain*        _skyMain;
    ScreenVC*       _screenVC;
    VideoManager*   _videoManager;
    MenuDock*       _menuDock;
}
@property (strong) MuNavigationC* muNavC;
@property (nonatomic,strong) UIWindow* window;

@end

