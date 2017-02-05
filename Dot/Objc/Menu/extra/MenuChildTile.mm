#import "MenuChildTile.h"
#import "ScreenView.h"
#import "SkyTr3Root.h"
#import "SkyPatch.h"
#import "ThumbBox.h"
#import "ThumbSwitch.h"
#import "ThumbTwist.h"
#import "ThumbSlider.h"



#define LogMenuChildTile(...)   //DebugLog(__VA_ARGS__)
#define PrintMenuChildTile(...) //DebugPrint(__VA_ARGS__)

@implementation MenuChildTile

- (id)initWithPatch:(SkyPatch*)patch_ {
    
    return [super initWithPatch:patch_];
#if 0 ///... 
    CGRect frame = CGRectMake(0,0, 220,188);
    
    self = [super initWithFrame:frame patch:patch_];

   CGFloat w = frame.size.width;

    [self initRuleOn:    CGRectMake(w-54,  6,  48, 32) cover:CGRectMake(64, 0, w-64, 52)];
    [self initModified:  CGRectMake(  10, 52,  56, 44)];
    [self initMirrorBox: CGRectMake(  10,106,  56, 56)];
    [self initRepeatBox: CGRectMake(  80, 52, 120,120)];
 
    // [self initBrushZero: CGRectMake( 10,172,  44,44)];
#endif
    return self;
}
#if 0 ///...
- (void)initRuleOn:(CGRect)frame cover:(CGRect)cover {
    
    string name = self.patch.name.lowercaseString.UTF8String;
    NSString *path = [NSString stringWithFormat:@"shader.%s.on",name.c_str()];
    UIImage* image = [UIImage.alloc initWithData:self.patch.thumb];
    
    _ruleOn = [ThumbSwitch.alloc initWithFrame:frame
                                         cover:cover
                                       tr3Path:path.UTF8String
                                         image:image
                                      duration:0
                                    completion:^(CGFloat p) {
                                        
                                        if (p==1) {
                                            [ScreenView.shared setShaderPatch:self.patch];
                                            [self updatePositionNow];
                                        } else {
                                            //Tr3Cache::set(_cellNow,"pause");
                                        }
                                    }];
    [self addSubview:_ruleOn];
}
- (void)initModified:(CGRect)frame {
    
    string name = self.patch.name.lowercaseString.UTF8String;
    NSString *path = [NSString stringWithFormat:@"shader.%s.changed",name.c_str()];
    
    _modified = [ThumbTwist.alloc initWithFrame:frame
                                          cover:frame
                                        tr3Path:path.UTF8String
                                            off:@"FlipOriginal128.png"
                                             on:@"FlipDelta128.png"
                                       duration:0
                                     completion:^(CGFloat p) {
        
        if (p==0) {
            [_repeatBox resetDefault];
            //[_mirrorBox resetDefault];
        }
        
    }];
    [self addSubview:_modified];
}
- (void)initMirrorBox:(CGRect)frame {
    
    
    _mirrorBox = [ThumbBox.alloc initWithFrame:frame
                                         title:@"Mirror"
                                      tr3Path:"screen.tile.mirror"
                                      startPos:CGPointMake(0,0)
                                     doubleTap:CGPointMake(1,1)
                                      duration:0
                                    completion:^(CGPoint value, CGFloat progress)
                  {
                      if (progress==0) {
                          _modified.position=1;
                      }
                      [ScreenView.shader setPoint:value name:@"mirror"];
                  }];
    
    [self addSubview:_mirrorBox];
}
- (void)initRepeatBox:(CGRect)frame {
    
    _repeatBox = [ThumbBox.alloc initWithFrame:frame
                                           title:@"Repeat"
                                        tr3Path:"screen.tile.repeat"
                                        startPos:CGPointMake(0,0)
                                       doubleTap:CGPointMake(-1,-1)
                                        duration:.5
                                      completion:^(CGPoint value, CGFloat progress)
                  {
                      if (progress==0) {
                          _modified.position=1;
                      }
                    
                      CGPoint repeat  = CGPointMake(max(1.0 - value.x, 0.01),
                                                    max(1.0 - value.y, 0.01));
                      
                      [ScreenView.shader setPoint:repeat name:@"repeat"];
                  }];
    
    [self addSubview:_repeatBox];
}
- (void)initBrushZero:(CGRect)frame {
    
    _brushZeroButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _brushZeroButton.frame = frame;
    [_brushZeroButton addTarget:self action:@selector(brushZeroAction:) forControlEvents:UIControlEventTouchUpInside];
    [_brushZeroButton setImage:[UIImage imageNamed:@"Drop128.png"] forState:UIControlStateNormal];
    [self addSubview:_brushZeroButton];
}
- (void)brushZeroAction:(id)sender {
    
    SkyRoot->bind("cell.rule.zero")->bang();
}
#endif

- (void)dealloc {
    
    self.dismissButton= 0;
}

- (void)onDismissButton {
    
    [self hideWithCompletion:nil];
}

- (void) updatePositionNow {
    
    [_repeatBox updatePositionWithCompletion];
    [_mirrorBox updatePositionWithCompletion];
}

#pragma mark - Menu Parent Dock

- (void)showChild {
    [super showChild];
}

- (void)MenuParentDoubleTap  {
    
    [_repeatBox resetDefault];
    [_mirrorBox resetDefault];
}

- (void)MenuParentSingleTap  {
    
    ////...  [ScreenView.shared setShaderPatch:self.patch];
    [self updatePositionNow];
}


@end
