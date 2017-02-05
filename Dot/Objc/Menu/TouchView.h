#import <UIKit/UIKit.h>
#import "Tr3.h"
#import "WorkLink.h"

@class MenuDock;

#define kAccelerometerFrequency 30 //Hz

@interface TouchItem : NSObject

@property(nonatomic, assign)CGPoint prev;
@property(nonatomic, assign)CGPoint next;
@property(nonatomic, assign)NSTimeInterval time;
@property(nonatomic, assign)CGFloat radius;
@property(nonatomic, assign)CGFloat force;
@property(nonatomic, assign)CGVector azimuth;
@property(nonatomic, assign)UITouchPhase phase;

- (id)initWithPrev:(CGPoint)prev_
              next:(CGPoint)next_
              time:(NSTimeInterval)time_
            radius:(CGFloat)radius_
             force:(CGFloat)force_
           azimuth:(CGVector)azimuth_
             phase:(UITouchPhase)phase_;
@end

@interface TouchView : UIView <WorkLinkDelegate,UIGestureRecognizerDelegate,UIAccelerometerDelegate> {
    
    // touches
    bool _localGesture; // pass through touches that start with 4 ios drag out panels
    UIResponder *_systemResponder;

    NSMutableDictionary* _touchFingers;

    Tr3* _tr3InputRadius; // finger radius
 
    Tr3* _tr3DrawBrushTilt;
    Tr3* _tr3DrawBrushPress;
    
    Tr3*   _tr3Line;
    
    Tr3*    _linePrev;
    float*  _linePrevX;
    float*  _linePrevY;
    
    Tr3*    _lineNext;
    float*  _lineNextX;
    float*  _lineNextY;
  
    Tr3*    _tr3Azimuth;   // apple pencil
    float*  _azimuthX;
    float*  _azimuthY;
    
    Tr3*    _tr3Force;

    Tr3*    _accel;        // accelerometer
    float*  _accelX;
    float*  _accelY;
    float*  _accelZ;
    
    Tr3*    _accelOn;
    
    Tr3*    _tr3Shake;     // not used?
}
@property(nonatomic,assign) CGSize margin;
+ (TouchView*)shared;

@end

