#import "../main/SkyDefs.h"
#import "../color/Colors.h"
#import <stdint.h>

struct Rgbs {

    int32_t _rgbNow;	// items used in rgb
    int32_t _rgbMax;	// maximum items in rgb
    Rgb*_rgbArray;    // top of array of Rgbs
    
    Rgbs ();
    
    void clear();
    bool ramp (Rgb&, Rgb&, int32_t);
    bool ramp (Hsv&, Hsv&, int32_t);
    bool resizeRgb (int32_t);
    bool fade (Rgbs&, Rgbs&, int32_t ratio);
    bool bw(float ratio);
    
    bool flip ();
    
    void addRgbs(Rgbs&); 
    void setRgbs(Rgbs&); 
};