#import "main.h"
#import "MenuChildShift.h"
#import "ThumbSlider.h"
#import "ThumbSwitch.h"
#import "ThumbTwist.h"
#import "ThumbBox.h"
#import "ThumbXY.h"
#import "CallIdSel.h"
#import "SkyTr3Root.h"
#import "SkyPatch.h"
#import "Tr3Find.h"

@implementation MenuChildShift

- (void)initRuleOn:(CGRect)frame cover:(CGRect)cover {
    
    _ruleOn = [ThumbSwitch.alloc initWithFrame:frame cover:cover tr3Path:"screen.shift.fake.on" off:@"LockClosedCircle.png" on:@"LockOpenCircle.png" duration:0 completion:^(CGFloat p) {
        if (p==0) {
            
            //_brushTilt.position=0;
            //_accelTilt.position=0;
            [_shiftBox setState:kMaster];
        }
        else {
            [_shiftBox setState:kSlave];
        }
    }];
    [self addSubview:_ruleOn];
}

- (void)initModified:(CGRect)frame {
    
    _modified = [ThumbTwist.alloc initWithFrame:frame
                                          cover:frame
                                        tr3Path:"screen.shift.fake.changed" off:@"FlipOriginal128.png"
                                             on:@"FlipDelta128.png"
                                       duration:0
                                     completion:^(CGFloat p)
                 {
                     
                     if (p==0) {
                         [self resetDefaults];
                     }
                 }];
    [self addSubview:_modified];
}

- (void)initShiftBox:(CGRect)frame {
    
    _shiftBox = (ThumbXY*)[ThumbBox.alloc initWithFrame:frame
                                        title:@"Shift"
                                      tr3Path:"screen.shift.fake.add"
                                     startPos:CGPointMake(.5,.5)
                                    doubleTap:CGPointMake(-1,-1)
                                     duration:.25
                                   completion:^(CGPoint p, CGFloat f) {
                                       
                                       if (f==0) {
                                           _ruleOn.position=1;
                                           _modified.position=1;
                                           _brushTilt.position=0;
                                           _accelTilt.position=0;
                                       }
                                   }];
    
    [self addSubview:_shiftBox];
    
}

- (void)initBrushTilt:(CGRect)frame {
    
    _brushTilt = [ThumbSwitch.alloc initWithFrame:frame cover:frame tr3Path:"draw.brush.tilt" off:@"BackFront.png" on:@"PenTilt.png" duration:0 completion:^(CGFloat p) {
        
        if (p==1) {
            
            _ruleOn.position=1;
            _accelTilt.position=0;
            [_shiftBox setState:kSlave];
            
        } else if (_brushTilt.position==0 &&
                   _accelTilt.position==0) {
            
            [_shiftBox setState:kMaster];
        }
    }];
    [self addSubview:_brushTilt];
}

- (void)initAccelTilt:(CGRect)frame {
    
    _accelTilt = [ThumbSwitch.alloc initWithFrame:frame cover:frame tr3Path:"input.accel.on" off:@"BackFront.png" on:@"Shift.png" duration:0 completion:^(CGFloat p) {
        
        if (p==1) {
            
            _ruleOn.position=1;
            _brushTilt.position=0;;
            [_shiftBox setState:kSlave];
            
        } else if (_brushTilt.position==0 &&
                   _accelTilt.position==0) {
            
            [_shiftBox setState:kMaster];
            
        }
    }];
    
    [self addSubview:_accelTilt];
}

- (void)resetDefaults {
    
    [_shiftBox resetDefault];
    _modified.position=0;
    _brushTilt.position=0;
    _accelTilt.position=0;
}

#pragma mark - MenuParentDelegate

- (void)showChild {
    
    [super showChild];
}


- (void)MenuParentDoubleTap  {
    
    [self resetDefaults];
}

- (void)MenuParentSingleTap  {

}


@end
