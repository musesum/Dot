#import "MenuParent.h"
#import "MenuParent+dragging.h"
#import "MenuDock.h"
#import "MenuDock+Reveal.h"
#import "MenuChild.h"

#import "CallIdSel.h"
#import "MenuDock.h"
#import "QuartzCore/CALayer.h"
#import "SkyPatch.h"
#import "Tr3.h"
#import "UIExtras.h"
#import "VideoManager.h"
#import "OrienteDevice.h"
#import "SkyDefs.h"

#define PrintMenuParent(...) //DebugPrint(__VA_ARGS__) /* orientation */
#define LogMenuParent(...) //DebugLog(__VA_ARGS__) /* touch parent */

#define DoubleTapTime .5

@implementation MenuParent

- (id)initWithName:(NSString*)name type:(NSString*)type img:(UIImage*)img menuChild:(MenuChild*)child target:(id)target {

    self = [super initWithImage:img blur: YES];

    _name = name;
    _skyType = type;
    _menuDock = MenuDock.shared;
    _menuChild = child;
    _target = target;
    
    _touchBeginTime = 0;
    _dragging = NO;
    _removing = NO;
    _touching = NO;
    return self;
}

#pragma mark - Touches


- (void) tap1 {
    
    [_menuDock relocateParent:self hideChild:YES];
    [_menuChild showMenu];
    [_menuDock shrinkDock];
}
- (void) tap2 {
    [_menuChild parentTap2];
}
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    fprintf(stderr," P "); ///???
    _touching = YES;
    _dragging = NO;
    self.removeableView = nil;

    UITouch* touch = [touches anyObject];
    _touchBeginPoint = [touch locationInView:nil];
    _touchMovedPoint = _touchBeginPoint;
    
    CFTimeInterval thisTime = CFAbsoluteTimeGetCurrent();
    double deltaBeginTouchTime = thisTime - _touchBeginTime;
    _touchBeginTime = thisTime;
    
    if (deltaBeginTouchTime < DoubleTapTime) {
        [_menuChild parentTap2];
    } else {
        [self tap1];
    }
}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject];
    _touchMovedPoint = [touch locationInView:nil];

    CGPoint deltaTouch = CGPointMake(_touchBeginPoint.x - _touchMovedPoint.x,
                                     _touchBeginPoint.y - _touchMovedPoint.y);
    
    [self startDraggingDeltaTouch:deltaTouch];
 }

- (void)endTouch:(UITouch*)touch {
    
    _touching = NO;
    _touchEndedPoint = [touch locationInView:nil];
    _menuDock.dragging = NO;
    CGPoint deltaTouch = CGPointMake(_touchBeginPoint.x - _touchMovedPoint.x,
                                     _touchBeginPoint.y - _touchMovedPoint.y);
    
    [self finishDraggingDeltaTouch:deltaTouch];
 }
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject];
    [self endTouch:touch];
}
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject];
    [self endTouch:touch];
}
@end
