#import "MenuChildRule.h"
#import "ThumbSlider.h"
#import "ThumbSwitch.h"
#import "ThumbTwist.h"
#import "ThumbSegment.h"
#import "ScreenView.h"
#import "Tr3Cache.h"
#import "SkyPatch.h"
#import "SkyTr3Root.h"


#define LogMenuChildRule(...)   // DebugLog(__VA_ARGS__)
#define PrintMenuChildRule(...) // DebugPrint(__VA_ARGS__)

#pragma mark - init

@implementation MenuChildRule

- (id)initWithPatch:(SkyPatch*)patch_ {
     return [super initWithPatch:patch_];
#if 0 ///...
    CGRect frame =CGRectMake(0,0,320,168);
    
    self = [super initWithFrame:frame patch:patch_];

    CGFloat w = frame.size.width;
    
    _cellNow = SkyRoot->bind("cell.now");
 
    [self initRuleOn:       CGRectMake(w-54,  6,  48, 32) cover:CGRectMake(64, 0, w-64, 52)];
    [self initModified:     CGRectMake(  10, 52,  48, 48)];
    [self initRuleVersion:  CGRectMake(  70, 52, 192, 44)];
    [self initBrushZero:    CGRectMake(  10,108,  44, 44)];
    [self initRulePlane:    CGRectMake(  70,108, 192, 44)];
    [self initBrushNine:    CGRectMake(w-54,108,  44, 44)];

    //[self initRealpal:    CGRectMake(  64,224, 192,44)];
#endif
    return self;
   }
#if 0 ///... 
- (void)initRuleOn:(CGRect)frame cover:(CGRect)cover {
    
    string name = self.patch.name.lowercaseString.UTF8String;
    NSString *path = [NSString stringWithFormat:@"cell.rule.%s.on",name.c_str()];
    _cellRuleOn = SkyRoot->bind(path.lowercaseString.UTF8String);
    UIImage* image = [UIImage.alloc initWithData:self.patch.thumb];

    
    _ruleOn = [ThumbSwitch.alloc initWithFrame:frame
                                         cover:cover
                                       tr3Path:path.UTF8String
                                         image:image
                                      duration:0
                                    completion:^(CGFloat p) {
        
        if (p==1) {
            Tr3Cache::bang(self.tr3CellRule);
        } else {
            Tr3Cache::set(_cellNow,"copy");
        }
    }];
    [self addSubview:_ruleOn];
}
- (void)initModified:(CGRect)frame {
    
    string name = self.patch.name.lowercaseString.UTF8String;
    NSString *path = [NSString stringWithFormat:@"cell.rule.%s.changed",name.c_str()];
    
    _modified = [ThumbTwist.alloc initWithFrame:frame cover:frame tr3Path:path.UTF8String off:@"FlipOriginal128.png" on:@"FlipDelta128.png" duration:0 completion:^(CGFloat p) {
        
        if (p==1) {
            [ScreenView.shared setShaderPatch:self.patch];
        } else {
            //Tr3Cache::set(_cellNow,"pause");
        }
    }];
    [self addSubview:_modified];
}
- (void)initBrushZero:(CGRect)frame {
    
    _brushZeroButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _brushZeroButton.frame = frame;
    [_brushZeroButton addTarget:self action:@selector(brushZeroAction:) forControlEvents:UIControlEventTouchUpInside];
    [_brushZeroButton setImage:[UIImage imageNamed:@"Drop128.png"] forState:UIControlStateNormal];
    [self addSubview:_brushZeroButton];
}
- (void)initBrushNine:(CGRect)frame {
    
    _brushNineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _brushNineButton.frame = frame;
    [_brushNineButton addTarget:self action:@selector(brushOneAction:) forControlEvents:UIControlEventTouchUpInside];
    [_brushNineButton setImage:[UIImage imageNamed:@"DropGray128.png"] forState:UIControlStateNormal];
    [self addSubview:_brushNineButton];
}
- (void)brushOneAction:(id)sender {
    
    Tr3* one = SkyRoot->bind("cell.rule.one");
    one->bang();
}
- (void)initRulePlane:(CGRect)frame {
    
    string name = self.patch.name.lowercaseString.UTF8String;
    NSString *path = [NSString stringWithFormat:@"cell.rule.%s.mix.plane",name.c_str()];
    
    _rulePlaneSlider = [ThumbSlider.alloc initWithFrame:frame tr3Path:path.UTF8String thumb:nil duration:0 completion:^(CGFloat value, CGFloat progress) {
        
        [[ScreenView shader] setFloat:1-value name:@"fade"];
    }];
    [self addSubview:_rulePlaneSlider];
}
- (void)brushZeroAction:(id)sender {
    
    Tr3* zero = SkyRoot->bind("cell.rule.zero");
    zero->bang();
}
- (void)initRuleVersion:(CGRect)frame {
    
    Tr3 *version = self.tr3CellRule->bind("version");
    
    _versionSegment = [ThumbSegment.alloc initWithFrame:frame tr3:version completion:nil];

    [self addSubview:_versionSegment];
}
#endif 

#pragma mark - MenuParentDelegate

- (void)showChild {
    
    string cellName = *_cellNow;
    ///... const char *myName = self.patch.name.lowercaseString.UTF8String;
    ///... bool running = strcmp(cellName.c_str(),myName)==0;
    ///... _ruleOn.position = (running ? 1 : 0);
    [super showChild];
}

- (void)MenuParentDoubleTap  {
    
    ///... [self brushZeroAction:nil];
}

- (void)MenuParentSingleTap  {
    
    _cellRuleOn->setNow(1);
    //??? self.tr3CellRule->bangAll();
    self.tr3CellRule->bang();
    _ruleOn.position=1;
}


@end
