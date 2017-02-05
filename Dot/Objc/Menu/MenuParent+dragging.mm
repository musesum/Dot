#import "MenuParent+dragging.h"
#import "MenuDock.h"
#import "MenuDock+Reveal.h"
#import "MenuChild.h"
#import "OrienteDevice.h"
#import "SkyDefs.h"

#define LogMenuParentDragging(...) //DebugLog(__VA_ARGS__) /* touch parent */

@implementation MenuParent (Dragging)

#pragma mark - Shrink to Location

- (void)shrinkToDragLocationAndRemove {
    
    //LogMenuParentDragging(@"MenuParent:%s ",sel_getName(_cmd));
    self.removing = YES;
    CGPoint removeableCenter = self.removeableView.center;
    [self.menuChild hideMenu]; // was hideWithCompletion:^
    
    {
        
        float radians = [OrienteDevice shared].deviceRadians;
        [UIView animateWithDuration:AnimateTimeMenuDock delay:0 options:AnimUserContinue animations:^{
            
            self.removeableView.transform = CGAffineTransformScale(CGAffineTransformRotate(CGAffineTransformIdentity,radians), .5, .5);
            self.removeableView.alpha = .8;
            
            self.removeableView.center = CGPointMake(removeableCenter.x, removeableCenter.y+14);
            float radians = [OrienteDevice shared].deviceRadians;
            self.transform = CGAffineTransformScale(CGAffineTransformRotate(CGAffineTransformIdentity,radians), .25, .25);
            self.center = CGPointMake(_touchEndedPoint.x,_touchEndedPoint.y-28);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:AnimateTimeMenuDock delay:0 options:AnimUserContinue animations:^{
                
                self.removeableView.alpha = 0;
                
            } completion:^(BOOL finished) {
                
                [self.removeableView removeFromSuperview];
                self.removeableView=nil;
                
                [self removeFromDock];
                
            }];
        }];
    }
}

- (void)removeFromDock {
    
    [_menuDock removeParent:self];
    [_menuDock relocateParents];
    
    [self removeFromSuperview];
    
    if ([_target respondsToSelector:@selector(MenuParentDraggedOut)]) {
        [_target performSelector:@selector(MenuParentDraggedOut)];
    }
    self.removing = NO;
}

- (bool)removeableViewFromDistance:(CGFloat)distanceY {
    
    bool removeable = distanceY > RemoveFromDockThreshold;
    float radians = [OrienteDevice shared].deviceRadians;
    
    if (removeable) {
        
        if (!_removeableView) {
            
            self.removeableView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"ParentCloud128.png"]];
            _removeableView.frame = CGRectMake(0,0, _removeableView.frame.size.width, _removeableView.frame.size.height);
            _removeableView.userInteractionEnabled=YES;
            
            [self.superview addSubview:_removeableView];
            _removeableView.center = CGPointMake(self.center.x, self.center.y-56);
            _removeableView.alpha = .1;
            _removeableView.transform = CGAffineTransformScale(CGAffineTransformRotate(CGAffineTransformIdentity,radians), .1, .1);
            
            [UIView animateWithDuration:AnimateTimeMenuDock delay:0 options:AnimUserContinue animations:^{
                _removeableView.alpha = .5;
                _removeableView.transform = CGAffineTransformScale(CGAffineTransformRotate(CGAffineTransformIdentity,radians),.5, .5);
            } completion:nil];
        }
        else {
            _removeableView.center = CGPointMake(self.center.x, self.center.y-56);
        }
    }
    else {
        
        if (_removeableView) {
            
            [UIView animateWithDuration:AnimateTimeMenuDock delay:0 options:AnimUserContinue animations:^{
                _removeableView.center = CGPointMake(self.center.x, self.center.y-56);
                _removeableView.alpha = .1;
                _removeableView.transform = CGAffineTransformScale(CGAffineTransformRotate(CGAffineTransformIdentity,radians), .1, .1);
            } completion:^(BOOL finished) {
                
                [_removeableView removeFromSuperview];
                self.removeableView=0;
            }];
        }
    }
    return removeable;
}

- (void)returnToParentRing {
    
    float radians = [OrienteDevice shared].deviceRadians;
    
    [UIView animateWithDuration:AnimateTimeMenuDock delay:0. options:AnimUserContinue animations:^{
        
        self.center = _menuDock.parentRing.center;
        self.transform = CGAffineTransformScale(CGAffineTransformRotate(CGAffineTransformIdentity,radians), _scale, _scale);
        
    } completion:^(BOOL finished) {
        
        [_menuDock initParentPositions];
    }];
}

#pragma mark - dragging

- (bool)draggingAwayFromDock:(CGPoint)delta {
    
    if ( self.tag <= 0 ||
        self.tag >= [_menuDock.parents count]-1)
        return NO;
    
    if ((_dragging || delta.y > UpdateDockThreshold) &&
        (_menuDock.state != kRevealHidden)) {
        [_menuChild hideMenu];
        return YES;
    }
    return NO;
}

/* shrink parent when dragging towards dock cursor */

#define ShrinkTowardsThreshold 32

- (bool)draggingTowardDock:(CGPoint)deltaTouch {
    
    if (deltaTouch.y > -ShrinkTowardsThreshold)
        return NO;

    /* 48 point cursor 128 point parent
     * TODO: allow for different cursor and parent sizes
     */
    static CGFloat RelativeWidth = .375;

    CGFloat cursorY = _menuDock.cursor.center.y;
    CGFloat calcY = self.calcCenter.y;
    CGFloat totalY = cursorY-calcY;
    CGFloat movedY = totalY+deltaTouch.y;
    CGFloat factor = RelativeWidth + (1-RelativeWidth)*MAX(0,movedY/totalY)*_scale;
    float radians = [OrienteDevice shared].deviceRadians;
    self.transform = CGAffineTransformScale(CGAffineTransformRotate(CGAffineTransformIdentity,radians), factor, factor);
    return YES;
}

- (bool)finishDraggingDeltaTouch:(CGPoint)deltaTouch {
    
    if (_dragging) {
        
        _dragging = NO;
        
        CGFloat distanceY = fabs(_touchBeginPoint.y-_touchEndedPoint.y);
        bool removable = [self removeableViewFromDistance:distanceY];
        
        if (removable) {
            
            [self shrinkToDragLocationAndRemove];
        }
        else if ([self draggingTowardDock:deltaTouch]) {

            [_menuDock shrinkDock];
        }
        else {
            [self returnToParentRing];
        }
        return YES;
    }
    else {
        return NO;
    }
}

/* when dragging parent test to see if moving towards or away from dock
 * - towards: shink size and allow to change position in dock
 * - away: allow change position in dock and allow remove from dock
 */
- (void)startDraggingDeltaTouch:(CGPoint)deltaTouch {

    if ([self draggingTowardDock:deltaTouch] ||
        [self draggingAwayFromDock:deltaTouch]) {
        
        if (!_dragging) {
            
            self.dragging = YES;
            _menuDock.dragging = YES;
        }
        [self removeableViewFromDistance:deltaTouch.y];
        self.center = _touchMovedPoint;
        [_menuDock updateDockForParent:self];
    }
}


@end
