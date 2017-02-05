#import "Colors.h"
#import "Rgbs.h"
#import "Tr3.h"

struct Ripple {
    
    Tr3* pulse;// number of frames to do ripples
    Tr3* width;
    Tr3* hue;
    Tr3* sat;
    Tr3* val;
    
    Hsv hsv;	// color to ripples through palette
    Rgb rgb;	// hsv converted to rgb
    Rgb draw[256];	// continuous palette
    
    int  now;	// current frame of fipple
    
    Ripple ();
    void bindTr3(Tr3*root);
    void start (Hsv&);
    bool going (Rgbs&);
};

