
#import "MenuDock+Reveal.h"
#import "MenuChild.h"
#import "TouchView.h"
#import "SkyMain.h"
#import "OrienteDevice.h"
#import "UIExtras.h"

#define PrintMenuDock(...) //DebugPrint(__VA_ARGS__)

#define Range(x,min,max) ((x)<(min) ? (min) : ((x)>(max) ? (max) :(x)))

@implementation MenuDock

+ (MenuDock*) shared {
    
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [self.alloc init];
    });
    return shared;
}

-(id) init {

    self = [super init];
    
    _localGesture = true;
    CGRect bounds = UIScreen.mainScreen.fixedCoordinateSpace.bounds;
    _cursorSize = CGSizeMake(48,48);
    CGRect frame  = CGRectMake(0,bounds.size.height-_cursorSize.height,bounds.size.width,_cursorSize.height);
    self.frame = frame;
    self.userInteractionEnabled = YES;
    
    _parentNames = [NSMutableDictionary.alloc init];
    _touchBeginTime = 0;
    _dockTimer = nil;
    bool isIpad = (UIDevice.currentDevice.userInterfaceIdiom==UIUserInterfaceIdiomPad);
    _minfactor = isIpad ? 1.25 : 1.0; // relative size of last place to 2nd and 3rd nearest
    _popFactor = isIpad ? 1.25 : 1.0; // popup size of 1st nearest to 2nd and 3rd nearest
    _maxFactor = _minfactor+_popFactor; // this get increased by getFactor for all factors
    
    _parentNow = nil;
    
    self.parentRing = [MenuView.alloc initWithImage:[UIImage imageNamed:@"dot.ring.white"] blur:NO];
    _parentRing.userInteractionEnabled = NO;
    _parentRing.scaled = 1;
    
    float dockSize = bounds.size.width-_cursorSize.width;
    _parentItem   = 0;
    _cursorPark   = CGPointMake(_cursorSize.width/2,bounds.size.height-_cursorSize.height/2);
    _cursorCenter = _cursorPark;
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    UIImage* img128 = [UIImage imageNamed:@"dot.ring.roygbiv.png"];
    UIImage* img48 = [UIImage imageWithImage:img128 scaledToSize:CGSizeMake(48,48)];
    _cursor = [UIImageView.alloc initWithImage:img48];
    //_cursor.frame.size = CGSizeMake(48, 48);
    _cursor.userInteractionEnabled = NO;
    _cursor.center = _cursorPark;
    
    _parents = [NSMutableArray arrayWithCapacity: 7];
    _moving = NO;
    
    UIView* tv = TouchView.shared;
    [tv addSubview:_parentRing];
    [tv addSubview:_cursor];
    [tv addSubview:self];

    // RevealTimer
    _dockStartTime = 0;
    _factor = .010;
    _remain = 1.2;
    return self;
}


- (void)resetOrientation {
    
    [UIView animateWithDuration:AnimateTimeMenuDock delay:0 options:AnimUserContinue animations:^{
        
        float radians = [OrienteDevice shared].deviceRadians;
        [_cursor setTransform: CGAffineTransformScale(CGAffineTransformRotate(CGAffineTransformIdentity,radians), 1, 1)];
        
        for (MenuParent*parent in _parents) {
        
            [parent reorientCenter];
            [parent.menuChild reorientCenter];
        }
    } completion:nil];
}

- (void)setOpaque:(BOOL)opaque {
    
    // Ignore attempt to set opaque to YES.
}

#pragma mark - Add Remove parents


- (void)removeParent:(MenuParent*)removeParent {
    
    int index = 0;
    
    for (MenuParent* parent in _parents) {
        
        if (parent == removeParent) {
            
            [_parents removeObjectAtIndex:index];
            [self initParentPositions];
            [_parentNow.menuChild hideMenu];
            [self relocateParent:[_parents objectAtIndex:0] hideChild:YES];
            return;
        }
        index++;
    }
}
- (void)removeAll {
    
    [_parents removeAllObjects];
    _parentNow = nil;
    _parentItem = 0;
}

- (void)updateDockForParent:(MenuParent*)parent {
    
    _parentNow = parent;
    
    [self growDock];
    [parent.menuChild hideMenu];
    
    CGPoint parentCenter = parent.touchMovedPoint;
    CGFloat deltaX = parent.touchMovedPoint.x-_parentRing.center.x;
    int parentTag = parent.tag;
    
    if (deltaX<0 && parentTag > 1) {
        
        MenuParent* priorParent = [_parents objectAtIndex:parentTag-1];
        
        if (parentCenter.x <= (parent.dockCenter.x + priorParent.dockCenter.x)/2) {
            
            [_parents removeObjectAtIndex:parentTag];
            [_parents insertObject:parent atIndex:parentTag-1];
            [self initParentPositions];
            _parentPosition = (float)parentTag-1;
            [self calcParentPositions];
            [self relocateParent:parent hideChild:YES];
        }
    }
    else if (deltaX > 0 && parentTag < _parents.count-2) {
        
        MenuParent* nextParent = [_parents objectAtIndex:parentTag+1];
        
        if (parentCenter.x > (parent.dockCenter.x + nextParent.dockCenter.x)/2) {
            
            [_parents removeObjectAtIndex:parentTag];
            [_parents insertObject:parent atIndex:parentTag+1];
            [self initParentPositions];
            _parentPosition = (float)parentTag+1;
            [self calcParentPositions];
            [self relocateParent:parent hideChild:YES];
        }
    }
}


#pragma mark - Relocate

/* expand parents and relocate cursor under main parent
 */

- (void)parentsLoop {

    double deltaTime = MIN(CFAbsoluteTimeGetCurrent() -_moveParentStart,RelocationInterval);
    float factor = deltaTime/RelocationInterval;
    CGPoint relocateCenter = _parentNow.calcCenter;
    float deltaX = (relocateCenter.x - _cursor.center.x)/2;
    float currentX = _cursor.center.x + deltaX*factor;
    
    CGPoint center = CGPointMake(currentX, _cursor.center.y);
    _cursor.center = center;
    
    [self arrangeParents];
    
    if (fabs(deltaX) <= 1) {
        [self.parentTimer invalidate]; _parentTimer = nil;
    }
}

- (void)relocateParents {
    
    _moveParentStart = CFAbsoluteTimeGetCurrent();
    [self.parentTimer invalidate]; _parentTimer = nil;
    self.parentTimer = [NSTimer scheduledTimerWithTimeInterval:LoopTime target:self selector:@selector(parentsLoop) userInfo:nil repeats:YES];
 }


/* called by MenuDock when updating dock and by  MenuParent::singleTap
 */
- (void)relocateParent:(MenuParent*)relocateParent_  hideChild:(bool)hideChild {
    
    _parentNow = relocateParent_;
    _relocateParent = relocateParent_;
    [self.parentTimer invalidate]; _parentTimer = nil;
    
    for (MenuParent*parent in _parents) {
        
        if (parent != _parentNow) {
            if (hideChild) {
                [parent.menuChild hideMenu];
            } else {
                [parent.menuChild hideUnpinned];
            }
        }
    }
    [self relocateParents];
}

#pragma mark - Arrange Parents

- (float)getFactor:(int)itemNow {
    
    float itemDelta = _parentPosition - (float)itemNow;
    float absItemDelta = fabs(itemDelta);
    float popup = (absItemDelta < 1.0 ? (1.0-absItemDelta): 0.0);
    float factor = _minfactor + _popFactor * (popup +  MIN(1.0,(1.0/(absItemDelta))));
    _maxFactor = MAX(_maxFactor,factor);
    return factor;
}

#define ParentNowFactor 1.4

- (void)calcParentPositions {
    
    float firstRadius = 0;
    float lastRadius = 0;
    float sumRunway = 0;
    float smallestFactor = 9999;
    float largestFactor = 0;
    float prevRadius = 0;
    
    for (int i=0; i<_parents.count; i++) {
        
        float factor = [self getFactor:i];
        smallestFactor = MIN(smallestFactor,factor);
        largestFactor  = MAX(largestFactor,factor);
        MenuParent* parent = [_parents objectAtIndex:i];
        
        float scale = (parent.dragging ? _maxFactor : factor);
        float radius = [parent radiusForScale:scale];
        
        sumRunway += parent.menuSize.width * scale * parent.scaled;
        prevRadius = radius;
        if (i==0) {
            firstRadius = radius;
        }
        else if (i==_parents.count-1) {
            lastRadius = radius;
        }
    }
    float thisRunway = self.frame.size.width-firstRadius-lastRadius;
    sumRunway = sumRunway-firstRadius-lastRadius;
    float factorRunway = thisRunway/sumRunway;
    
    prevRadius = 0;
    float nowCenter = firstRadius;
    float deltaFactor = largestFactor-smallestFactor;
    if (deltaFactor == 0)
        deltaFactor = 1;
    
    CGSize screenSize = UIScreen.mainScreen.fixedCoordinateSpace.bounds.size;
    CGFloat height = MAX(screenSize.height,screenSize.width);
    
    for (int i=0; i<_parents.count; i++) {
        
        MenuParent* parent = [_parents objectAtIndex:i];
        float factor = [self getFactor:i];
        
        float scale = (parent.dragging ?  _maxFactor : factor);
        float radius = [parent radiusForScale:scale];//radius = parent.radius;
        
        nowCenter = (i==0 ? radius : nowCenter + (prevRadius+radius) *factorRunway);
        
        prevRadius = radius;
        float centerX = nowCenter;
        float factori = (factor-smallestFactor)/deltaFactor;
        float centerY =  height - radius - (_cursorSize.height * factori);
        parent.calcCenter = CGPointMake(centerX, centerY);
    }
}

- (void)initPositionsAtIndex:(int)index {
    
    _parentItem = (int)index;
    _parentPosition = (float)_parentItem;
    [self calcParentPositions];
}

- (void)initParentPositions {

    for (int index = 0; index < _parents.count; index++) {
        
        [self initPositionsAtIndex:index];
        MenuParent*parent = [_parents objectAtIndex:index];
        parent.tag = index;
    }
}

/* menuParent dots never go outside display area
 * so calculate the range for cursor between
 * first and last button, when they are fully expanded
 */

- (void)calcCursorPosition {
    
    MenuParent* firstParent = [_parents firstObject];
    MenuParent* lastParent  = [_parents lastObject];
    
    float firstFactor = [self getFactor:0];
    float lastFactor  = [self getFactor:_parents.count-1];
    firstParent.scale = firstFactor;
    lastParent.scale  = lastFactor;

    float _firstCenterX  = firstParent.calcCenter.x; // only cursor
    float _lastCenterX   = lastParent.calcCenter.x;

    _cursorCenter.x =  Range (_cursor.center.x,_firstCenterX, _lastCenterX);
    
    if (_cursorCenter.x <=_firstCenterX) {
        
        _cursorCenter.x =_firstCenterX;
        _parentItem = 0;
        _parentPosition = 0;
    }
    else if (_cursorCenter.x >= _lastCenterX) {
        
        _cursorCenter.x = _lastCenterX;
        _parentItem = _parents.count-1;
        _parentPosition = _parents.count-1;
    }
    else {
        float minDelta = 999999;
        
        for (int i=0; i<_parents.count; i++) {
            
            MenuParent*parent = [_parents objectAtIndex:i];
            float deltaX = parent.calcCenter.x - _cursorCenter.x;
            
            if (fabs(deltaX) < fabs(minDelta)) {
                minDelta = deltaX;
                _parentItem = i;
            }
        }
        int nextParentPosition = (minDelta > 0 ? max(0,_parentItem-1) : MIN(_parents.count-1,_parentItem+1));
        MenuParent* nextParent = [_parents objectAtIndex:nextParentPosition];
        MenuParent* nearParent = [_parents objectAtIndex:_parentItem];
        float deltaParentX = nextParent.calcCenter.x - nearParent.calcCenter.x;
        _parentPosition = (deltaParentX==0
                           ? _parentItem
                           : _parentItem + fabs(minDelta)/deltaParentX);
    }
}

- (void)arrangeParents {
    
    [self calcParentPositions];
    
    MenuParent* parentPrev = _parentMax;
    _parentMax = (_parentNow ? _parentNow : [_parents firstObject]);
    
    for (int i=0; i<_parents.count; i++) {
        
        MenuParent*parent  = [_parents objectAtIndex:i];
        parent.tag = i;
        float deltaX = parent.calcCenter.x - _cursor.center.x;
        float deltaY = parent.calcCenter.y - _cursor.center.y;
        float revealX = parent.calcCenter.x - deltaX * self.remain;
        float revealY = parent.calcCenter.y - deltaY * self.remain;
        
        parent.dockCenter = CGPointMake(revealX, revealY);
        
        // TODO: parent.scale = n has side effects, make more obvious
        if (parent.dragging) {
            parent.center = parent.touchMovedPoint;
            parent.scale = _maxFactor;
        }
        else {
            
            CGFloat factor = MAX(self.factor,  (parent==_parentNow ? .4 : .001));
            parent.scale = [self getFactor:i]*factor;
            parent.center = CGPointMake(revealX, revealY);
        }
        
        if (_parentMax.scale < parent.scale) {
            _parentMax = parent;
        }
    }
    [self arrangeParentViews];
    
    if (_parentMax != parentPrev) {
        [parentPrev.menuChild hideMenu];
        [_parentMax.menuChild showMenu];
        _parentNow = _parentMax;
    }
    [self.superview bringSubviewToFront:self];
}
- (void)arrangeParentViews {
    
    bool foundSelection = NO;
    
    // stack preceeding views forwards
    for (int i=0; i<_parents.count; i++) {
        
        MenuParent* parent = [_parents objectAtIndex:i];
        if (parent == _parentNow) {
            foundSelection = YES;
        }
        [self.superview bringSubviewToFront:parent];
        if (i==_parentItem)
            break;
    }
    // stack successor views backwards
    for (int i=_parents.count-1; i>=0; i--) {
        
        MenuParent* parent = [_parents objectAtIndex:i];
        if (parent == _parentNow) {
            foundSelection = YES;
        }
        [self.superview bringSubviewToFront:parent];
        
        if (i==_parentItem)
            break;
    }
    [self.superview bringSubviewToFront:_cursor];
    
    if (!foundSelection) {
        
        _parentNow = nil;
        _parentRing.alpha = 0;
    }
    else {
        _parentRing.alpha = 1;
        _parentRing.scale = _parentNow.scale;
        PrintMenuDock("*** %.2f ",_parentNow.scale);
        
        _parentRing.center = (_parentNow.dragging
                              ? _parentNow.calcCenter
                              : _parentNow.dockCenter);
        [self.superview insertSubview:_parentRing aboveSubview:_parentNow];
    }
   
}
#pragma mark - touches

/* This dock's response to UITouches start near the cursor.
 * The dock actually spans the whole width of the screen
 * but lets some gestures through to the drawing layer
 * depending on where it starts. See below, for details.
*/

- (void)beganTouch:(UITouch*)touch {
    
    CFTimeInterval thisTime = CFAbsoluteTimeGetCurrent();
    double deltaBeginTime   = thisTime - _touchBeginTime;
    _touchBeginTime  = thisTime;
    _touchBeginPoint = [touch locationInView:nil];
    
    _moving = NO;
    
    if (deltaBeginTime < .5) {
        
        [_parentNow tap2];
    }
    else {
        [self growDock];
    }
}
- (void)moveTouch:(UITouch*)touch {

    CGPoint touchPoint = [touch locationInView:nil];

    /* set threshold for _moving when delta > 8 point,
     * but only when moving at least 8 points away from enter */
    CGFloat deltaX = MIN(fabs(touchPoint.x - _touchBeginPoint.x),
                         fabs(touchPoint.x - _cursor.center.x));
    
    /* animate when crossing threshold for moving curso*/
    if (!_moving && deltaX > 8) {
        
        _moving = YES;
        _cursor.center = CGPointMake(touchPoint.x, _cursor.center.y);
        _cursorCenter = _cursor.center;
        [self calcCursorPosition];
        [self arrangeParents];
    }
    /* if already moving, then simply update cursor position */
    else if (_moving) {
        
        _cursorCenter = CGPointMake(touchPoint.x, _cursor.center.y);
        _cursor.center = _cursorCenter;
        [self calcCursorPosition];
        [self arrangeParents];
    }
}

- (void)endTouch:(UITouch*)touch {
    
    _moving = NO;
    [self shrinkDock];
}

/* Respond only when gesture starts near cursor
 * below is the logic for when to respond
 * above is the actual dock response
 */
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [event touchesForView:self].anyObject;
    CGPoint p = [touch locationInView:nil];
    
    switch (_state) {
            
        case kRevealHidden: {

            CGFloat deltaX = fabs(_cursor.center.x - p.x);
            _localGesture = (deltaX < 64);
            break;
        }
        case kRevealShrinking:
        case kRevealGrowing:
        case kRevealShowing:
            
            _localGesture = true;
            break;
    }
    fprintf(stderr," D%i ",_localGesture); ///???
    
    if (_localGesture) {  [self beganTouch:touch]; }
    else { [self.nextResponder touchesBegan:touches withEvent:event]; }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    
    if (_localGesture) { [self moveTouch:[event touchesForView:self].anyObject]; }
    else { [self.nextResponder touchesMoved:touches withEvent:event]; }
}
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    
    if (_localGesture) { [self endTouch:[event touchesForView:self].anyObject]; }
    else { [self.nextResponder touchesEnded:touches withEvent:event]; }
}
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    
    if (_localGesture) { [self endTouch:[event touchesForView:self].anyObject];}
    else {  [self.nextResponder touchesCancelled:touches withEvent:event];  }
}

@end
