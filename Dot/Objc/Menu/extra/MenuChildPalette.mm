#import "MenuChildPalette.h"
#import "MenuDock.h"
#import "MenuDock+Reveal.h"
#import "MenuChild.h"

#import "SkyMain.h"
#import "SkyMain+Patch.h"
#import "ThumbSlider.h"
#import "ScrubView.h"

#import "MuPalettePicker.h"
#import "AppDelegate.h"
#import "UIImageRgbs.h"
#import "CallIdSel.h"
#import "VideoManager.h"
#import "UIExtras.h"
#import "SkyPatch.h"
#import "ScreenView.h"
#import "OrienteDevice.h"
#import "Shader.h"
#import "MuDrawCircle.h"
#import "MuDrawDot.h"
#import "Tr3Cache.h"
#import "MuNavigationC.h"

#import "SkyTr3Root.h"
#import "ScreenVC.h"


#define LogMenuChildPalette(...)  // DebugLog(__VA_ARGS__)
#define PrintMenuChildPalette(...) // DebugPrint(__VA_ARGS__)

#pragma mark - init

/* TODO: Mix plane was taken out, so slider wont do anything
 * this should be put back in when it works and instead
 * replace the BrushSize, not the PalIndex, as it is now
 */
#define UseRulePlane 0

@implementation MenuChildPalette


- (id)initWithPatch:(SkyPatch*)patch {
    
    CGRect frame =  CGRectMake(0,0,320,176);
    self = [super initWithFrame:frame patch:patch];
    
    CellMain* cellMain = [SkyMain.shared cellMain];
    _pals = &(cellMain->pic.pix.pals);
    _pals->goPal();
 
    _tr3MainFrame = SkyRoot->Tr3Bind2("main.frame",Tr3MenuPaletteFrame);
    
    CGFloat w = frame.size.width;
    
    [self initPalZero:      CGRectMake(  10, 50,  44,44)];
    [self initPalSlider:    CGRectMake(  64, 50, 192,44)];
    [self initPalOne:       CGRectMake(w-54, 50,  44,44)];
    
    [self initPalShiftLeft: CGRectMake(  10,108,  44,44)];
    [self initPalShiftRight:CGRectMake(w-54,108,  44,44)];
    [self initPalScrub:     CGRectMake(  64,108, 192,44)];
    
    return self;
}


void Tr3MenuPaletteFrame(Tr3*from,Tr3CallData*data) {
    
    __block id target = (__bridge id)(data->_instance);
    dispatch_async(dispatch_get_main_queue(), ^{
        [target goFrame];
    });
}

- (void)goFrame {

    if (self.showState==kShowing) {
    
        float offset = (float)*(_pals->cycle.ofs);
        
        if (_palCycleOffset != offset) {
            _palCycleOffset = offset;
            [self updateScrubViewImage];
        }
    }
}


- (void)readPalettePatchName:(NSString*)name withChanges:(WithChangesType)changes {
    
    SkyPatch* patch = [SkyPatch readPatchName:name withUniverse:NO];
    SkyMain* skyMain = [SkyMain shared];
    [skyMain parsePatch:patch];
    [skyMain setPatchNow:patch];

    if (patch.pal1) {
        Tr3Cache::flush();
        //[self goApp];
    }
}

- (void)initPalSlider:(CGRect)frame {
    
    _palXfadeSlider = [ThumbSlider.alloc initWithFrame:frame tr3Path:"pal.change.xfade" thumb:nil duration:0.25 completion:^(CGFloat value, CGFloat progress) {
        
        [self updateScrubViewImage];
    }];
    [self addSubview:_palXfadeSlider];
}
/* left  button for palette picker
 */
- (void)initPalZero:(CGRect)frame {
    
    _palButtons = [NSMutableArray.alloc init];
    
    
    UIButton* palButton = [UIButton buttonWithType:UIButtonTypeCustom];
    palButton.frame = frame;
    [palButton addTarget:self action:@selector(palButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    palButton.tag = kLeftButton;
    
    [self addSubview:palButton];
    [_palButtons addObject:palButton];
    [self updateButtonImageIndex:0];
}

- (void)updateButtonImageIndex:(int)index {
    
    CGSize thumbSize = CGSizeMake(92, 92);
    UIImage* thumb       = [UIImageRgbs imageFromRgbs:&(_pals->pal[index].rgbs) size:thumbSize];
    UIImage* roundThumb  = [thumb imageWithRoundedCornersForSize:thumbSize];
    UIImage* button      = [UIImage imageNamed:@"ParentRing128.png"];
    UIImage* buttonThumb = [button imageAddImage:roundThumb under:NO];
    [[_palButtons objectAtIndex:index] setImage:buttonThumb forState:UIControlStateNormal];
}

/* right button for palette picker
 */
- (void)initPalOne:(CGRect)frame {
    UIButton* palButton = [UIButton buttonWithType:UIButtonTypeCustom];
    palButton.frame = frame;
    [palButton addTarget:self action:@selector(palButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    palButton.tag = kRightButton;
    [self addSubview:palButton];
    [_palButtons addObject:palButton];
    [self updateButtonImageIndex:1];
}

- (void)initPalScrub:(CGRect)frame {
    
    CellMain* cellMain = [SkyMain.shared cellMain];
    _pals = &(cellMain->pic.pix.pals);
    
    Rgbs*rgbs = &(_pals->final);
    UIImage*scrubImage =  [UIImageRgbs imageFromRgbs:rgbs size:CGSizeMake(256, 32)];
    
    _scrubView = [ScrubView.alloc initWithFrame:frame
                                            image:scrubImage
                                           update:^{[self ScrubViewUpdate];}
                                            reset:^{[self ScrubViewReset];}];
    _scrubView.frame = frame;
    
    
    // brush index
    
    _brushIndexSlider = [ThumbSliderParent.alloc initWithFrame:frame tr3Path:"draw.brush.index" thumb:@"Brush2Thumb.png" duration:0 parent:(UIImageView*)_scrubView completion:^(CGFloat value, CGFloat progress) {
        [self updateBrushDot:value];
    }];
    _brushIndexSlider.dot.radius = 8;
    [_scrubView addSubview:_brushIndexSlider];
    [self addSubview:_scrubView];
    
}

- (void)ScrubViewReset {
    
    // user double tapped finger in scr
    //LogMenuChildPalette(@"MenuChildPalette::%s",sel_getName(_cmd));
    _pals->cycle.ofs->setNow(0.);
    _pals->cycle.inc->setNow(0.);
    _pals->goPal();
    [self updateScrubViewImage];
}

- (void)ScrubViewUpdate {
    
    // user moved finger in scrub palette
    CGPoint deltaPoint = _scrubView.deltaPoint;
    //PrintMenuChildPalette(@"\nscrubAction deltaPoint(%.f,%.f)", sel_getName(_cmd),deltaPoint.x, deltaPoint.y);
    int offset = *(_pals->cycle.ofs);
    _pals->cycle.ofs->setNow(offset+deltaPoint.x/2);
    _pals->cycle.inc->setNow(0.);
    _pals->goPal();
    [self updateScrubViewImage];
}

- (void)updateScrubViewImage {
    
    _scrubView.imageView.image = [UIImageRgbs imageFromRgbs:&(_pals->final) size:CGSizeMake(256, 32)];
    [self updateBrushDot:_brushIndexSlider.position];
}

- (void)updateBrushDot:(CGFloat)v {
    
    int index = (int)(v*256);
    if (index>255) {
        return;
    }
    Rgbs*rgbs = &(_pals->final);
    Rgb rgb = rgbs->_rgbArray[index];
    [_brushIndexSlider.dot setColor:ColorRGBA((float)rgb.r/256.,(float)rgb.g/256.,(float)rgb.b/256.,1)];
    [_brushIndexSlider.dot setNeedsDisplay];
}

- (void)initPalShiftLeft:(CGRect)frame {
    
    _shiftLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    _shiftLeft.frame = frame;
    
    UIImageView* buttonView = [UIImageView.alloc initWithFrame:CGRectMake(0,0,64,64)];
    buttonView.image = [UIImage imageNamed:@"ArrowLeft.png"];
    [_shiftLeft setImage:buttonView.image forState:UIControlStateNormal];
    
    [_shiftLeft addTarget:self action:@selector(shiftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _shiftLeft.tag = 1;
    [self addSubview:_shiftLeft];
}

- (void)initPalShiftRight:(CGRect)frame {
    
    _shiftRight = [UIButton buttonWithType:UIButtonTypeCustom];
    _shiftRight.frame = frame;
    
    UIImageView* buttonView = [UIImageView.alloc initWithFrame:CGRectMake(0,0,64,64)];
    buttonView.image = [UIImage imageNamed:@"ArrowRight.png"];
    [_shiftRight setImage:buttonView.image  forState:UIControlStateNormal];
    
    [_shiftRight addTarget:self action:@selector(shiftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _shiftRight.tag = 2;
    [self addSubview:_shiftRight];
}
// currently unused
- (void)initRealPal:(CGRect)frame {
    
    string name = *self.tr3CellNow;
    NSString *path = [NSString stringWithFormat:@"cell.rule.%s.mix.plane",name.c_str()];
    _realpalSlider = [ThumbSlider.alloc initWithFrame:frame tr3Path:path.UTF8String thumb:nil duration:0 completion:^(CGFloat value, CGFloat progress) {
        [[ScreenView shader] setFloat:value name:@"fade"];
    }];
    
    [self addSubview:_realpalSlider];
}
// shift

- (void)shiftButtonAction:(id)sender {
    
    UIButton* button = (UIButton*)sender;
    int tag = button.tag;
    Tr3*inc = _pals->cycle.inc;
    if (tag==1) {
        inc->decrementNow();
    }
    else {
        inc->incrementNow();
    }
    [self updateScrubViewImage];
}

// pal buttons


#pragma mark - picker buttons

- (void)palButtonClicked:(id)sender {
    
    UIButton* button = (UIButton*)sender;
    LeftRightTag tag = (LeftRightTag)button.tag;
    AppDelegate* app = (AppDelegate*)UIApplication.sharedApplication.delegate;
    
    [MenuDock.shared shrinkDock];
    
    _palPicker = [MuPalettePicker.alloc initWithCompletion:^(NSDictionary*d) {
        
        NSNumber* palTagNum = [d objectForKey:@"palTag"];
        
        if (palTagNum) {
            
            int palTag = [palTagNum integerValue];
            _pals->pal[tag].copy(*(_pals->preset[palTag]));
            _pals->goFade();
            [self updateButtonImageIndex:tag];
            [self updateScrubViewImage];
            [self goFrame];
            [ScreenVC.shared dismissViewControllerAnimated:NO completion:nil];
        }
    }];
    
    MuPicker *picker = [MuPicker.alloc initWithParentVC:ScreenVC.shared contentVC:_palPicker];
    [picker startPickerView:button];
}

- (void)updatePositionNow {
    [_palXfadeSlider updatePositionWithCompletion];
}

#pragma mark - Menu Parent Dock

- (void)showChild {
    
    [super showChild];
    [self updateScrubViewImage];
}

- (void)MenuParentSingleTap  {
    
    // look for user tweeks to default palette
    //[self readPalettePatchName:name withChanges:kWithChangesActive];
    [self readPalettePatchName:self.menuParent.patchName withChanges:kWithChangesActive];
}

- (void)MenuParentDoubleTap {
    
    // look for user tweeks to default palette
    SkyRoot->bind("cell.rule.zero")->bang();
}
@end
