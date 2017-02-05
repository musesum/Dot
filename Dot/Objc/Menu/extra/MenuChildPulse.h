#import "MenuChild.h"
#import "ColorRGBA.h"
#import "Colors.h"

struct Tr3;
struct SkyTr3Recorder;
@class SkyPatch;

@interface MenuChildPulse : MenuChild {
    
    
    double _lastTime;
    Hsv _hsv;
    Rgb _rgb;
    ColorRGBA _color;  
    
    NSTimer* _waitTimer;
    
    Tr3* _tr3MainFrame;
    Tr3* _tr3Hue;
    Tr3* _tr3Sat;
    Tr3* _tr3Val;
    Tr3* _tr3Dur;
    SkyTr3Recorder* _tr3Recorder;

    CGFloat _radiusBorder;
    MuDrawCircle* _edge;
}

@property (nonatomic, readonly) ColorRGBA color;
@property (nonatomic,strong) MuDrawCircle* edge;
@property (nonatomic) Hsv hsv;
@property (nonatomic) Rgb rgb;

- (id)initWithPatch:(SkyPatch*)patch_;

- (void)getPixelColorAtLocation:(CGPoint)point;
- (CGPoint)constrict:(CGPoint)point_;

@end