#import "main.h"

struct Tr3;
struct Tr3Osc;
@class VideoManager;
@class MenuDock;


@protocol WorkLinkDelegate <NSObject>
- (void)NextFrame;
@end

@interface WorkLink: NSObject {
    
    CADisplayLink *displayLink;
    VideoManager *_videoManager;

    bool _active;
    Tr3* _tr3MainFrame;
    Tr3Osc *_tr3Osc;
    MenuDock *_menuDock;
}
+(WorkLink*)shared;
@property(strong,nonatomic) NSMutableArray *delegates;
@end
