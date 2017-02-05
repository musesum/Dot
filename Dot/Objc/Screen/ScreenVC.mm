#import "ScreenVC.h"
#import "ScreenView.h"
#import "Tr3.h"
#import "OrienteDevice.h"

#define PrintScreenVC(...)  DebugPrint(__VA_ARGS__)
@implementation ScreenVC

+(id) shared {
    
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [self.alloc init];
    });
    return shared;
}

- (id) init {
    
    self = [super init];
    CGRect bounds = UIScreen.mainScreen.fixedCoordinateSpace.bounds;
    _screenView = [ScreenView.shared initWithFrame:bounds];
    self.view = _screenView;
    self.wantsFullScreenLayout = YES;
    
     return self;
}

- (void)initTr3Root:(Tr3*)root {
    
    Tr3*projector       = root->bind("sky.screen.projector");
    _tr3ProjectorWidth  = projector->bind("width");
    _tr3ProjectorHeight = projector->bind("height");
    _tr3ProjectorOn     = projector->bind("on");
}

- (CGSize)getMargin {
    return _screenView.vertex.margin;
}
- (void)viewDidLoad {
    
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)setupScreen2WithRootVC:(UIViewController*)rootVC_ {
    
    _rootVC = rootVC_;
    
    if ((int)*_tr3ProjectorOn != 1) {
        return;
    }

    _screen = [[UIScreen screens] objectAtIndex:0];
    _screen2 = nil;
    _window2 = nil;
    
	if ([[UIScreen screens] count] > 1) {
        
        [self initScreen2:[[UIScreen screens] objectAtIndex:1]];
    }
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleScreenConnectNotification:) name:UIScreenDidConnectNotification object:nil];
    [center addObserver:self selector:@selector(handleScreenDisconnectNotification:) name:UIScreenDidDisconnectNotification object:nil];
    _window2.backgroundColor = UIColor.blackColor;
}

- (void) initScreen2:(UIScreen*)connectedScreen {
    
    CGRect frame = connectedScreen.bounds;
    if (!_window2)
        _window2 = [UIWindow.alloc initWithFrame:frame];
    
    _screen2 = connectedScreen;
    
     CGSize user = CGSizeMake(*_tr3ProjectorWidth, *_tr3ProjectorHeight);

    
    UIScreenMode* userMode = nil;
    UIScreenMode* mode1920x1080p = nil;
    UIScreenMode* mode1280x768p = nil;
    UIScreenMode* mode1280x720p = nil;
    UIScreenMode* mode1024x768p = nil;
    NSArray* availableModes = [_screen2 availableModes];
    
    for (UIScreenMode* mode in availableModes) {
        
        CGSize size = mode.size;
        NSLog(@"Screen mode: %.f %.f",size.width, size.height);
        
        if (size.width == user.width && size.height == user.height) { userMode = mode; }
        else if (size.width == 1920 && size.height == 1080) { mode1920x1080p = mode; }
        else if (size.width == 1280 && size.height == 720) { mode1280x720p = mode; }
        else if (size.width == 1280 && size.height == 768) { mode1280x768p = mode; }
        else if (size.width == 1024 && size.height == 768) { mode1024x768p = mode; }
    }
    
    if      (userMode)       { _screen2.currentMode = userMode; }
    else if (mode1920x1080p) { _screen2.currentMode = mode1920x1080p; }
    else if (mode1280x768p)  { _screen2.currentMode = mode1280x768p; }
    else if (mode1280x720p)  { _screen2.currentMode = mode1280x720p; }
    else if (mode1024x768p)  { _screen2.currentMode = mode1024x768p; }
    
    [_window2 setScreen:connectedScreen];
    _window2.hidden = NO;
    UIViewController* vc = [[UIViewController alloc]initWithNibName:nil bundle:nil];
    _window2.rootViewController = vc;
    ScreenView* view = [_screenView initSecondScreenViewWithFrame:frame];
    [_window2 addSubview:view];
}

- (void) handleScreenConnectNotification:(NSNotification*)notification {
    [self initScreen2:[notification object]];
}


- (void)handleScreenDisconnectNotification:(NSNotification*)aNotification {
    
    if (_window2) {
        
        // remove offscreen view
        _screenView.self2 = 0; // memory?
        
        // Hide and then delete the window.
        _window2.hidden = YES;
        
        _window2 = nil;
        
        // Update the main screen based on what is showing here.
        //[viewController displaySelectionOnMainScreen];
    }
}


@end
