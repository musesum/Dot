#import "MenuParent.h"
#import "SkyMain.h"
#import "CallIdSel.h"
#import "Shader.h"

typedef enum {
    kHidden         = 0,
    kAnimateToShow  = 1,
    kShowing        = 2,
    kAnimateToHide  = 4,
}   ShowState;

@interface MenuChild: MenuView {
    
    MenuParent*         _menuParent;
    
    bool                _pinned; // future pinning down
    ShowState           _showState;
    CGAffineTransform   _rotation;
    
    UILabel*            _titleLabel;
    NSString*           _titleText;
    
    CGRect              _dismissFrame;
    CGRect              _titleFrame;
    
    NSMutableArray*     _controls;
}

@property (nonatomic,strong) MenuParent* menuParent;
@property (nonatomic,strong) UILabel*    titleLabel;
@property (nonatomic,strong) NSString*   title;
@property (nonatomic,strong) UIButton*   dismissButton;

@property bool pinned;

- (id)initWithTr3:(Tr3*)tr3;
- (void)showMenu;
- (void)hideMenu;
- (void)hideUnpinned;
- (void)refresh;
- (void)parentTap2;

@end

