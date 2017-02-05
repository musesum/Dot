#import "main.h"
#import "MenuChildWeave.h"
#import "ThumbSlider.h"
#import "CallIdSel.h"
#import "ScreenView.h"
#import "Pals.h"
#import "Rgbs.h"
#import "MuDrawCircle.h"
#import "Tr3.h"
#import "Tr3Cache.h"
#import "CellMain.h"
#import "SkyPatch.h"
#import "ThumbBox.h"
#import "ThumbSwitch.h"
#import "SkyTr3Root.h"

#define LogMenuChildRule(...)    // DebugLog(__VA_ARGS__) 
#define PrintMenuChildRule(...) //DebugPrint(__VA_ARGS__) 

@implementation MenuChildWeave

- (id)initWithPatch:(SkyPatch*)patch_  {

    CGRect frame = CGRectMake(0,0,312,202);
    CGFloat w = frame.size.width;
    
    self = [super initWithFrame:frame patch:patch_];
    [self initRuleOn:    CGRectMake(w-54,  6,  48, 32) cover:CGRectMake(64, 0, w-64, 52)];
    [self initSpreadBox:  CGRectMake( 16, 52, 128,128)];
    [self initDivideBox:  CGRectMake(160, 52, 128,128)];
    
    return self;
}


- (void)initRuleOn:(CGRect)frame cover:(CGRect)cover {
    
    string name = self.patch.name.lowercaseString.UTF8String;
    NSString *path = [NSString stringWithFormat:@"shader.%s.on",name.c_str()];
    UIImage* image = [UIImage.alloc initWithData:self.patch.thumb];
    
    _ruleOn = [ThumbSwitch.alloc initWithFrame:frame cover:cover tr3Path:path.UTF8String image:image duration:0 completion:^(CGFloat p) {
        
        if (p==1) {
            [ScreenView.shared setShaderPatch:self.patch];
            [self updatePositionNow];

        } else {
            //Tr3Cache::set(_cellNow,"pause");
        }
    }];
    [self addSubview:_ruleOn];
}

- (void)initSpreadBox:(CGRect)frame {
    
    _spreadBox = [ThumbBox.alloc initWithFrame:frame
                                         title:@"Spread"
                                       tr3Path:"screen.weave.spread"
                                      startPos:CGPointMake(0, 0)
                                     doubleTap:CGPointMake(-1,-1)
                                      duration:.5
                                    completion:^(CGPoint p, CGFloat f)
                  {
                      [[ScreenView shader] setPoint:p name:@"spread"];
                  }];
    [self addSubview:_spreadBox];
}

- (void)initDivideBox:(CGRect)frame {
    
    _divideBox = [ThumbBox.alloc initWithFrame:frame
                                         title:@"Divide"
                                       tr3Path:"screen.weave.divide"
                                      startPos:CGPointMake(0,0)
                                     doubleTap:CGPointMake(-1,-1)
                                      duration:.5
                                    completion:^(CGPoint p, CGFloat f)
                  {
                      [[ScreenView shader] setPoint:p name:@"divide"];
                  }];
    [self addSubview:_divideBox];
}

- (void) updatePositionNow {
    
    [_spreadBox updatePositionWithCompletion];
    [_divideBox updatePositionWithCompletion];
}

#pragma mark - MenuParentDelegate

- (void)showChild {
    
    [super showChild];
    [self updatePositionNow];
}

- (void)MenuParentDoubleTap  {
    
    [ScreenView.shared setShaderPatch:self.patch];
    [_spreadBox resetDefault];
    [_divideBox resetDefault];
}

- (void)MenuParentSingleTap {
    
    [ScreenView.shared setShaderPatch:self.patch];
}


@end
