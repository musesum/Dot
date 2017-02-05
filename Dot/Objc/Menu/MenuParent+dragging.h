#import "MenuParent.h"


#define RemoveFromDockThreshold 120
#define UpdateDockThreshold 32

@interface MenuParent (Dragging)

- (void)shrinkToDragLocationAndRemove;
- (void)removeFromDock;
- (bool)draggingAwayFromDock:(CGPoint)delta;
- (bool)draggingTowardDock:(CGPoint)deltaTouch;
- (bool)removeableViewFromDistance:(CGFloat)distanceY;
- (bool)finishDraggingDeltaTouch:(CGPoint)deltaTouch;
- (void)startDraggingDeltaTouch:(CGPoint)deltaTouch;
@end
