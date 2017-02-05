#import "MenuChildBrush.h"
#import "ThumbSlider.h"
#import "ThumbSwitch.h"
#import "Tr3Cache.h"
#import "SkyTr3Root.h"
#import "Completion.h"

@implementation MenuChildBrush

- (id)initWithPatch:(SkyPatch*)patch_ {
    
    CGRect frame =CGRectMake(0,0,320,168);
    
    self = [super initWithFrame:frame patch:patch_];

    CGFloat w = frame.size.width;
 
    [self initBrushZero:  CGRectMake(  10, 50,  44,44)];
    [self initPalScrub:   CGRectMake(  64, 50, 192,44)];
    [self initBrushNine:  CGRectMake(w-54, 50,  44,44)];
    
    [self initBrushPress: CGRectMake(  10,108,  66,44)];
    [self initBrushSize:  CGRectMake(  86,108, 206,44)];
    
    return self;
   }

- (void)initBrushSize:(CGRect)frame {
    
    _brushSize = [ThumbSlider.alloc initWithFrame:frame tr3Path:"draw.brush.size" thumb:nil duration:0 completion:^(CGFloat value, CGFloat progress) {
        
        _brushPress.position = 0;
     }];

    [self addSubview:_brushSize];
}

- (void)initBrushPress:(CGRect)frame {
    
    _brushPress = [ThumbSwitch.alloc initWithFrame:frame
                                             cover:frame
                                           tr3Path:"draw.brush.press"
                                               off:@"BackFront.png"
                                                on:@"PenPress.png"
                                          duration:0
                                        completion:^(CGFloat p) {
                                            [_brushSize setState:(p==1 ? kSlave : kMaster)];
                                            
                                        }];
    
    [self addSubview:_brushPress];
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

- (void)initBrushNine:(CGRect)frame {
    
    _brushNineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _brushNineButton.frame = frame;
    [_brushNineButton addTarget:self action:@selector(brushOneAction:) forControlEvents:UIControlEventTouchUpInside];
    [_brushNineButton setImage:[UIImage imageNamed:@"DropGray128.png"] forState:UIControlStateNormal];
    [self addSubview:_brushNineButton];
}

- (void)brushOneAction:(id)sender {
    
    SkyRoot->bind("cell.rule.one")->bang();
}

#pragma mark - MenuParentDelegate

- (void)showChild {
    
    [super showChild];
    [self updateScrubViewImage];
}

- (void)MenuParentDoubleTap  {
    
    [self brushZeroAction:nil];
}

- (void)MenuParentSingleTap  {

    Tr3Cache::bang(self.tr3CellRule);
}


@end
