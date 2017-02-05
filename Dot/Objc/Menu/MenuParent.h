#import "MenuView.h"

@class MenuDock;
@class MenuChild;
@class SkyPatch;

#define RemoveFromDockThreshold 120
#define UpdateDockThreshold 32

@interface MenuParent : MenuView {
    
    MenuDock* _menuDock;
    id _target;
 
    NSTimer* _afterTouchTimer;
    CFTimeInterval _touchBeginTime;
    
    CGPoint _touchBeginPoint;
    CGPoint _touchMovedPoint;
    CGPoint _touchEndedPoint;

    CGPoint _calcCenter;
    UIImageView* _removeableView;
    bool _dragging;
    MenuChild* _menuChild;
}

@property bool touching;
@property bool dragging;
@property bool removing;

@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) MenuChild* menuChild;
@property (nonatomic) CGPoint touchMovedPoint;
@property (nonatomic) CGPoint calcCenter; // calculated center irregardless of updating with finger
@property (nonatomic) CGPoint dockCenter; // position in dock, may be separate form self.center while dragging around
@property (nonatomic,strong) UIImageView* removeableView;
@property (nonatomic) NSString* skyType;
@property (nonatomic) bool selected;

- (id)initWithName:(NSString*)name type:(NSString*)type img:(UIImage*)img menuChild:(MenuChild*)child target:(id)target_;

- (void)tap1;
- (void)tap2;
@end
