#import "GestureV.h"
#import "OrienteDevice.h"
#import "SkyTr3Root.h"
#import "Tr3Cache.h"
#import "MenuDock.h"
#import "ScreenVC.h"

#define LogGesture(...) DebugLog(__VA_ARGS__)
#define PrintGesture(...) //DebugPrint(__VA_ARGS__)

@implementation TouchItem

- (id)initWithPrev:(CGPoint)prev_
              next:(CGPoint)next_
              time:(NSTimeInterval)time_
            radius:(CGFloat)radius_
            force:(CGFloat)force_
           azimuth:(CGVector)azimuth_
             phase:(UITouchPhase)phase_{
    
    self = [super init];
    
    _prev = prev_;
    _next = next_;
    _time = time_;
    _radius = radius_;
    _force = force_;
    _azimuth = azimuth_;
    _phase = phase_;
    
    return self;
}

@end

#pragma mark - GestureV

@implementation GestureV

+(GestureV*) shared {
    
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [self.alloc init];
    });
    return shared;
}

- (id) init {
    
    self = [super init];
    self.frame = UIScreen.mainScreen.fixedCoordinateSpace.bounds;
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    self.backgroundColor = UIColor.clearColor;
    
    ScreenVC* svc = ScreenVC.shared;
    [self initWithMargin:svc.getMargin responder:svc.view];
    [svc.view addSubview:self];
    return self;
}

- (void)initWithMargin:(CGSize)margin_ responder:(UIResponder*)responder_{
    

       // touches
    
    _margin = margin_;
    _systemResponder = responder_;
    _touchFingers = [NSMutableDictionary dictionary];
    
    Tr3*sky             = SkyRoot->bind("sky");
    
    // drawing
    _tr3InputRadius     = sky->bind("input.radius");
    _tr3DrawBrushTilt   = sky->bind("draw.brush.tilt"); //TODO: put this in "menu.brush.tilt"
    _tr3DrawBrushPress  = sky->bind("draw.brush.press"); //TODO: put this in "menu.brush.press"
    
    _tr3Line    = sky->bind("draw.shape.line");
    
    _linePrev   = _tr3Line->bind("prev");
    _linePrevX  = (*_linePrev)[0];
    _linePrevY  = (*_linePrev)[1];
    
    _lineNext   = _tr3Line->bind("next");
    _lineNextX  = (*_lineNext)[0];
    _lineNextY  = (*_lineNext)[1];
  
    // motion
    
    Tr3* input  = sky->bind("input");
    _tr3Shake   = input->bind("shake");
    
    _tr3Azimuth = input->bind("azimuth");
    _azimuthX   = (*_tr3Azimuth)[0];
    _azimuthY   = (*_tr3Azimuth)[1];
    
    _tr3Force   = input->bind("force");

    _accel      = input->bind("accel");
    _accelX     = (*_accel)[0];
    _accelY     = (*_accel)[1];
    _accelZ     = (*_accel)[2];
    _accelOn    = _accel->bind("on");
    
    if (_linePrevX && _linePrevY &&
        _lineNextX && _lineNextY &&
        _azimuthX  && _azimuthY) {
        
        [WorkLink.shared.delegates addObject:self];
    }
    if (_accelX && _accelY && _accelZ) {
        [UIAccelerometer.sharedAccelerometer setUpdateInterval:(1.0 / kAccelerometerFrequency)];
        [UIAccelerometer.sharedAccelerometer setDelegate:self];
    }
}

#pragma mark - Touches

- (CGPoint)normalizedPoint:(CGPoint)p {
    
    static CGRect bounds = UIScreen.mainScreen.fixedCoordinateSpace.bounds;
    
    static float cX = bounds.size.width/2; // center X
    static float cY = bounds.size.height/2; // center Y
    static float xFactor = 1-_margin.width*2;
    static float yFactor = 1-_margin.height*2;
    
    CGPoint delta = CGPointMake( (p.y-cY),-(p.x-cX)); // delta
    
    CGPoint n = CGPointMake((.5 + delta.x/bounds.size.height*yFactor),
                            (.5 + delta.y/bounds.size.width*xFactor)); // normalized point
    return n;
}

/* NextFrame is WorkLink delegate that is called 30 or 60 frames per second.
 * Meanwhile, one or more fingers may have sent a touch event, in the interim.
 *
 * Because there may be more than one touch event for each finger, it is
 * saved in an array.
 *
 * Sometimes the user holds down a finger without moving it. So,
 * the last touch event is save to be redrawn for the next frame.
 *
 * When the user lives a finger or is cancelled, the array of events
 * for that finger is removed from the dictionary.
 */
- (void)NextFrame {
    
    NSArray* allKeys = [_touchFingers allKeys];
    
    for (NSString* key in allKeys) {
        
        NSMutableArray* finger = [_touchFingers objectForKey:key];
        bool touching = YES;
        
        for (TouchItem* item in finger) {
            
            //PrintTouchesManyToTr3Line("A:(%i) ",[array count]);
            CGPoint prevNorm = [self normalizedPoint:item.prev];
            CGPoint nextNorm = [self normalizedPoint:item.next];
            
            *_linePrevX = prevNorm.x; *_linePrevY = prevNorm.y;
            *_lineNextX = nextNorm.x; *_lineNextY = nextNorm.y;
            
            // if menu brush press is turned on
            if (*_tr3DrawBrushPress) {
                if (item.force > 0) {
                    _tr3Force->setNow(item.force);
                } else {
                    _tr3InputRadius->setNow(item.radius);
                }
            }
            // if using Apple Pencil and menu brush tilt is turned on
            if (item.force > 0 && *_tr3DrawBrushTilt) { 
                *_azimuthX = item.azimuth.dx; // is this ranged?
                *_azimuthY = item.azimuth.dy;
                _tr3Azimuth->bang();
            }
            _tr3Line->bang();
            
            //PrintGesture("N:(%.f,%.f)->(%.3f,%.3f)\n", item.next.x, item.next.y, *_lineNextX, *_lineNextY);
            
            // has this finger stopped touching?
            switch (item.phase) {
                    
                case UITouchPhaseBegan:
                case UITouchPhaseMoved:
                case UITouchPhaseStationary:
                    break;
                    
                case UITouchPhaseEnded:
                case UITouchPhaseCancelled:
                    touching = NO;
            }
        }
        if (touching) {
            // remove all but last touch to repeat
            TouchItem* lastItem = [finger lastObject];
            [finger removeAllObjects];
            [finger addObject:lastItem];
        }
        else {
            // remove all non-touching fingers from array
            [_touchFingers removeObjectForKey:key];
        }
    }
}

/* Add new touches to be drawn in the NextFrame, above.
 * During the lifecycle of a touch, the memory address of
 * a specific touch remains the same, so use that as a key
 * into a dictionary of _touchFingers to retrieve an
 * array of events. If this is the first time for a new finger
 * then create a new array and add it dictionary of _touchFingers.
 */
- (void)updateTouches:(NSSet*)touches withEvent:(UIEvent*)event {
    
    NSTimeInterval time = [event timestamp];
    
    for (UITouch* touch in touches) {
        
        // create a touch time
        CGPoint prev = [touch previousLocationInView:nil];
        CGPoint next = [touch locationInView:nil];
        CGFloat radius = [touch majorRadius];
        CGVector azimuth = [touch azimuthUnitVectorInView:nil];
        CGFloat force = [touch force];
        
        CGFloat azi = [touch azimuthAngleInView:nil];
        CGFloat alt = (M_PI_2-[touch altitudeAngle])/M_PI_2;
        CGVector vec = CGVectorMake(-sin(azi)*alt,cos(azi)*alt);
        
        UITouchPhase phase = touch.phase;
        TouchItem* item = [TouchItem.alloc initWithPrev:prev next:next time:time radius:radius force:force azimuth:vec phase:phase];
        //PrintGesture("<%p>%i:(%.f,%.f)->(%.f,%.f) ",touch, phase, prev.x,prev.y,next.x,next.y);
        
        // add touch item to a finger
        NSString* touchKey = [NSString stringWithFormat:@"%p",touch];
        NSMutableArray* touchItems = [_touchFingers objectForKey:touchKey];
        if (!touchItems) {
            touchItems = [NSMutableArray array];
            [_touchFingers setObject:touchItems forKey:touchKey];
        }
        [touchItems addObject:item];
    }
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    static CGFloat w = UIScreen.mainScreen.fixedCoordinateSpace.bounds.size.width;
    static CGFloat h = UIScreen.mainScreen.fixedCoordinateSpace.bounds.size.height;
    static CGRect home = CGRectMake(w/2-40, h-40, 80, 40); // cover of home button
    static CGFloat w0 = w/2-40;
    static CGFloat w1 = w/2+40;
    static CGFloat h0 = h/2-40;
    static CGFloat h1 = h/2+40;
 

    UITouch* touch = touches.anyObject;
    CGPoint p = [touch locationInView:nil];
    
    _localGesture = true;
    
    if (p.x >= w0 && p.x <= w1) {           // horizontal center
        if (p.y <= 40 || p.y >= h-40) {     // vertical edges
            
            _localGesture = false;
        }
    }
    else if (p.y >= h0 && p.y <= h1) {      // vertical edges
        if (p.x <= 40 || p.x >= w-40) {     // horizontal center
            
            _localGesture = false;
        }
    }
    
    if (_localGesture) {
        
        [self updateTouches:touches withEvent:event];
    }
    else {
    
        [_systemResponder touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    
    if (_localGesture) {
        [self updateTouches:touches withEvent:event];
    }
    else {
        [_systemResponder touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    
    if (_localGesture) {
        [self updateTouches:touches withEvent:event];
    }
    else {
        [_systemResponder touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    
    if (_localGesture) {
        [self updateTouches:touches withEvent:event];
    }
    else {
        [_systemResponder touchesCancelled:touches withEvent:event];
    }
}

#pragma mark - motion

- (BOOL)isFirstResponder {
    return YES;
}
- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent*)event {
    
    if (motion == UIEventSubtypeMotionShake) {
        _tr3Shake->bang(); //vp crashes with video
    }
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent*)event {
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent*)event {
}

- (void)accelerometer:(UIAccelerometer*)accelerometer 
        didAccelerate:(UIAcceleration*)acceleration {
    
    static UIAccelerationValue xx,yy,zz;
    
#define kFilteringFactor 0.1
#define kMinEraseInterval 0.5
#define kEraseAccelerationThreshold 2.0
    
	//Use a basic high-pass filter to remove the influence of the gravity
	xx = acceleration.x * kFilteringFactor + xx * (1.0 - kFilteringFactor);
	yy = acceleration.y * kFilteringFactor + yy * (1.0 - kFilteringFactor);
	zz = acceleration.z * kFilteringFactor + zz * (1.0 - kFilteringFactor);

    static CFTimeInterval firstTime = CFAbsoluteTimeGetCurrent();
    static CFTimeInterval nextTime = firstTime;
    if (false && *_accelOn) {
        *_accelX = -yy;
        *_accelY = -xx;
        *_accelZ =  zz;
        Tr3Cache::bang(_accel);
    }
	//Compute the intensity of the current acceleration and if above a given threshold, erase our drawing view
    // orientation is not accurate for first 2 seconds so skip
    
     if (nextTime-firstTime < 2.0)  {
        nextTime = CFAbsoluteTimeGetCurrent ();
        return;
    }
}

@end
