#import "AppDelegate.h"
#import "SkyTr3Root.h"
#import "SkyTr3.h"
#import "SkyMain.h"
#import "MenuDock.h"
#import "MenuDock+Add.h"
#import "MenuChild.h"
#import "ScreenVC.h"
#import "ScreenView.h"
#import "VideoManager.h"
#import "SoundEffect.h"

#import "MuNavigationC.h"
#import "Tr3Script.h"

#define PrintAppDelegate(...)  //DebugPrint(__VA_ARGS__) /* app delegate */

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    
    UIApplication.sharedApplication.statusBarHidden = YES;
    self.window.frame = UIScreen.mainScreen.fixedCoordinateSpace.bounds;
    [self.window makeKeyAndVisible];
    
    SkyRoot = new Tr3("√");
    _screenVC = ScreenVC.shared; // init this first to setup OpenGL pipeline
    _skyTr3   = SkyTr3.shared;
    _skyMain  = SkyMain.shared;
    _menuDock = MenuDock.shared;
    
    [_menuDock addSkyRoot:SkyRoot]; // will parse tr3 script that includes shaders
    [_screenVC initTr3Root:SkyRoot];
    [[ScreenView shared] updateShaderName:@"Tile"];
    [_menuDock splashWithCompletion:^{_skyTr3.skyActive=YES;}];
    
    [_skyTr3 openDotURL:[launchOptions valueForKey:@"UIApplicationLaunchOptionsURLKey"]];
    _videoManager = VideoManager.shared;
    
    // nav controller with main and alternate windows
    _muNavC = [MuNavigationC.alloc initWithRootViewController:_screenVC];
    [_muNavC setNavigationBarHidden:YES];
    [_window setRootViewController:_muNavC];
    [_screenVC setupScreen2WithRootVC:_muNavC];
    [UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];
    
    return YES;
}


- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url {   
    
    if (!url) {
        return NO;
    }
    NSString* URLString = [url absoluteString];
    if (!URLString) {
        return NO;
    }
    NSInteger maximumExpectedLength = 220;
    if ([URLString length] > maximumExpectedLength) {
        return NO;
    }
    [_skyTr3 pushSkyActive:NO];
    [_skyTr3 openDotURL:url];
    [_skyTr3 setSkyActive:YES];
    return YES;
}

#pragma mark - App State

- (void)applicationWillResignActive:(UIApplication*)application {
    
    PrintAppDelegate("\nApplication Did Resign Active ");
    
    [_videoManager setActive:NO];
    [_skyTr3 pushSkyActive:NO];
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
    
    PrintAppDelegate("\nApplication Did Become Active ");
    
    [_videoManager setActive:YES];
    [_skyTr3 setSkyActive:YES];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application {
}

- (void)applicationDidEnterBackground:(UIApplication*)application {
    
    [_skyTr3 pushSkyActive:NO];
    //!! [_skyMain saveSystemPlacemark];
    [_videoManager setActive:NO];

    PrintAppDelegate("\nApplication Did Enter Background ");
}

- (void)applicationWillEnterForeground:(UIApplication*)application {
    
    PrintAppDelegate(@"applicationWillEnterForeground");

    [_videoManager setActive:YES]; //!!
    [_skyTr3 popSkyActive:YES];
    [MenuDock.shared.parentNow.menuChild refresh];
}

- (void)applicationWillTerminate:(UIApplication*)application {
    
   PrintAppDelegate(@"applicationWillTerminate");
   
    [_window bringSubviewToFront:_screenVC.view];
    //!! [_skyMain saveSystemPlacemark];
    //!! [_skyMain writeLastImageFromType];
}

@end
