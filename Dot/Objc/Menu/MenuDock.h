#import "MenuParent.h"
#import "RevealState.h"
#import "Completion.h"

#define AnimateTimeMenuDock .5
#define LoopTime (1./60.) /* loop timer interval of animate timer */
#define RelocationInterval .5

@class MenuView;

@protocol RevealTimerDelegate;

@interface MenuDock: UIView {
    
    CGSize _cursorSize;
    CGPoint _cursorCenter;
    UIImageView*_cursor;
    
    float _minfactor; // relative size of last place to 2nd and 3rd nearest
    float _popFactor; // popup size of 1st nearest to 2nd and 3rd nearest
    float _maxFactor; // largest calculated factor
    
    int   _parentItem;      // cursor is pointing to i'th item in list
    float _parentPosition;  // x position for x, account for dock margin
    NSMutableDictionary*_parentNames;
    MenuParent* _relocateParent;       // selected parent, used to animate curosor underneath
    
    bool            _localGesture; // user is doing something on dock
    CGPoint         _touchBeginPoint;
    CFTimeInterval  _touchBeginTime;   // time of most recent TouchesBegin
    CFTimeInterval  _moveParentStart;

    bool _moving; // only arrange parents for large finger movements
    
    CFTimeInterval _dockStartTime; //used by RevealTimer

    MenuParent* _parentMax; // highest (largest) Parent Dot
    MenuParent* _selectedNow; // push/pop parent section
    MenuParent* _selectedPrev; // push/pop parent section
    
}
@property bool dragging; // user is manually dragging parent around dock
@property (atomic,strong) NSTimer* parentTimer; // parentsLoop <- relocateParents <-
@property (atomic,strong) NSTimer* dockTimer;   // animateDock <- updateDock
@property (nonatomic,strong) UIImageView*cursor;

@property (nonatomic,strong) NSMutableArray* parents;
@property (nonatomic,strong) MenuView* parentRing;
@property (nonatomic,strong) MenuParent* parentNow;

@property (nonatomic) CGPoint cursorCenter; // adjusted cursor to occomadate growing parents
@property (nonatomic) CGPoint cursorPark; // leftmost parking position for cursor

// RevealTimer
@property(nonatomic,assign) Float32 factor;
@property(nonatomic,assign) Float32 remain;
@property(nonatomic,assign) RevealState state;

+ (MenuDock*) shared;


- (void)removeParent:(MenuParent*)removeParent;
- (void)removeAll;
- (void)updateDockForParent:(MenuParent*)parent;
- (void)initParentPositions;
- (void)initPositionsAtIndex:(int)index;
- (void)relocateParents;
- (float)getFactor:(int) itemNow;
- (void)calcParentPositions;
- (void)relocateParent:(MenuParent*)relocateParent_ hideChild:(bool)hideChild;
- (void)calcCursorPosition;
- (void)arrangeParents;
- (void)resetOrientation;

@end

