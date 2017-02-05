#import "CellMain.h"
#import "SoundEffect.h"
#import "ImageFromType.h"
#import "WorkLink.h"
#import "ParPar.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "Tr3Expand.h"

struct Tr3;

@class VideoManager;
@class AppNetworkView;
@class MenuDock;

@interface SkyMain : NSObject<WorkLinkDelegate> {

    BOOL _pushSkyActive;
    Tr3* _tr3CellGo;        // execute cellular automata
    Tr3* _tr3CellNow;      // current CA rule - lowercase
    Tr3* _tr3Shake;
    Tr3* _tr3PalChangeMix;

    SoundEffect*    _erasingSound;
    
    CVPixelBufferRef _cvPixelBufferRef;
    VideoManager*   _videoManager;
    AppNetworkView* _appNetworkView;
    MenuDock*       _menuDock;
    ParPar          _parPar;
}

@property(nonatomic) ImageFromType imageFrom;
@property(nonatomic) CellMain *cellMain;
@property(nonatomic) CGSize skySize;
@property(nonatomic) BOOL skyActive;
@property(nonatomic) bool needsUpdate;
@property(nonatomic) bool dockLocked;
@property bool eraseUniverse;

+ (id)shared;

- (void)openDotURL:(NSURL*)url;
- (void)setSkyActive:(BOOL)skyActive_;
- (void)pushSkyActive:(BOOL)skyActive_;
- (void)popSkyActive:(BOOL)skyActive_ ;

- (void)parseTr3:(NSString*)tr3;

void Tr3Shake(Tr3*from,Tr3CallData*data);
- (void)erase;
- (void)getNextFrame;
@end
