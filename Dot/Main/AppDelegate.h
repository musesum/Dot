#import "main.h"

@class SkyMain;
@class ScreenVC;
@class VideoManager;
@class SoundEffect;
@class MuNavigationC;
@class MenuDock;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    
    SkyMain*        _skyMain;
    ScreenVC*       _screenVC;
    VideoManager*   _videoManager;
    MenuDock*       _menuDock;
}
@property (strong) MuNavigationC* muNavC;
@property (nonatomic,strong) UIWindow* window;
@end

