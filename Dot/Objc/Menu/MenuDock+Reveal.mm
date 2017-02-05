
#import "MenuDock+Reveal.h"
#import "MenuParent.h"
#import "MenuChild.h"

#import "CubicPoly.h"

#define PrintMenuDockReveal(...) DebugPrint(__VA_ARGS__)

#define AnimateTime 0.25
#define WaitTime  4

@implementation MenuDock (Reveal)


/* animate dock growing and shrinking with little extra bounce
 * using an interpolated catmul-rom so smooth out the point
 * with a point(x,y), where x==time and y==factor
 */

- (Vec2D)timePointFromFactor:(float)timeFactor {

    /* p0...p3 are the points in which to draw a curve */
    static Vec2D p0 = Vec2D( .0,  .0);
    static Vec2D p1 = Vec2D( .3,  .5);
    static Vec2D p2 = Vec2D( .7, 1.2);
    static Vec2D p3 = Vec2D(1.0, 1.0);
    
    static CubicPoly px[3],py[3]; //coeficients for p0...p3
    
    static bool firstTime = YES;
    if (firstTime) {
        firstTime = NO;
        CubicPoly::InitCentripetalCR(p0,p0,p1,p2,px[0],py[0]);
        CubicPoly::InitCentripetalCR(p0,p1,p2,p3,px[1],py[1]);
        CubicPoly::InitCentripetalCR(p1,p2,p3,p3,px[2],py[2]);
    }
   
    Vec2D timePoint = ( (timeFactor < 1./3.) ? CubicPoly::eval((timeFactor      )*3, px[0],py[0])
                       :(timeFactor < 2./3.) ? CubicPoly::eval((timeFactor-1./3.)*3, px[1],py[1])
                       :                       CubicPoly::eval((timeFactor-2./3.)*3, px[2],py[2]));
    
    return timePoint;
}

- (void)animateDock {
    
    CFTimeInterval thisTime = CFAbsoluteTimeGetCurrent();
    double deltaTime = thisTime - _dockStartTime;
    
    switch (self.state) {
            
        case kRevealGrowing: {
            
            float timeFactor = MIN(1.0, deltaTime/AnimateTime);
            Vec2D timePoint = [self timePointFromFactor:timeFactor];
            self.factor = timePoint.y;
            self.remain = 1 - self.factor;
            
            [self arrangeParents];
            [self.parentNow.menuChild reorientCenter];
            
            if (deltaTime >= AnimateTime) {
                
                [self.dockTimer invalidate];  self.dockTimer = 0;
                self.state = kRevealShowing;
                PrintMenuDockReveal("+");
            }
            return;
        }
        case kRevealShrinking: {
            
            float timeFactor = 1- MIN(1.0, deltaTime/AnimateTime);
            Vec2D timePoint = [self timePointFromFactor:timeFactor];
            self.factor = timePoint.y;
            self.remain = 1 - self.factor;
            
            [self arrangeParents];
            [self.parentNow.menuChild reorientCenter];
            
            if (deltaTime >= AnimateTime) {
                
                [self.dockTimer invalidate]; self.dockTimer = 0;
                self.state = kRevealHidden;
                PrintMenuDockReveal("-");
                
                [self.superview bringSubviewToFront:self];
             }
            return;
        }
        case kRevealShowing:
            PrintMenuDockReveal("▭");
            return;
        case kRevealHidden:
            PrintMenuDockReveal(".");
            return;
    }
}

// callers: growDock, shrinkDock

- (void)updateDock {
 
    [self.dockTimer invalidate];
    _dockStartTime = CFAbsoluteTimeGetCurrent();
    self.dockTimer = [NSTimer scheduledTimerWithTimeInterval:LoopTime target:self selector:@selector(animateDock) userInfo:nil repeats:YES];
}

- (void)growDock {
    
    switch (self.state) {
            
        case kRevealGrowing: 
        case kRevealShowing:
            return;
            
        case kRevealHidden:
        case kRevealShrinking:                     

            self.state = kRevealGrowing;
            [self updateDock];
            return;
    }
}


- (void)shrinkDock {
    
    [self relocateParent:self.parentNow hideChild:NO];
    self.state = kRevealShrinking;
    [self updateDock];
}

@end
