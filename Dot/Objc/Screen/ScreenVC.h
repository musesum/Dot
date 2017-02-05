#import "main.h"

@class ScreenView;
struct Tr3;

@interface ScreenVC : UIViewController {
    
    UIScreen *_screen;
    UIScreen *_screen2;
    UIViewController*_rootVC;
    
    Tr3* _tr3ProjectorWidth;
    Tr3* _tr3ProjectorHeight;
    Tr3* _tr3ProjectorOn;
}

@property (nonatomic,strong) UIWindow  *window2;
@property (nonatomic,strong) ScreenView *screenView;

+ (id)shared;
- (void)initTr3Root:(Tr3*)root;
- (void)setupScreen2WithRootVC:(UIViewController*)rootVC_;
- (CGSize)getMargin;

@end
