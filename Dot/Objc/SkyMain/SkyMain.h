#import "CellMain.h"
#import "SoundEffect.h"
#import "ImageFromType.h"
#import "WorkLink.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "Tr3Expand.h"

struct Tr3;

@class SkyTr3;
@class VideoManager;
@class AppNetworkView;
@class MenuDock;

@interface SkyMain : NSObject<WorkLinkDelegate> {

    SkyTr3*         _skyTr3;
    SoundEffect*    _erasingSound;
    
    CVPixelBufferRef _cvPixelBufferRef;
    VideoManager*   _videoManager;
    AppNetworkView* _appNetworkView;
    MenuDock*       _menuDock;
}
+ (id)shared;
- (void)getNextFrame;
@end
