#import <MacTypes.h>

struct ColorRGBA {
    
    Float32 red, green, blue, alpha;
    
    ColorRGBA() {
        red=1; green=1; blue=1; alpha=1;
    }
    ColorRGBA(Float32 red_, Float32 green_, Float32 blue_, Float32 alpha_) {
        red=red_; green=green_; blue=blue_; alpha=alpha_;
    }
    ColorRGBA& operator = (const ColorRGBA &c_) {
        
        red   = c_.red; 
        blue  = c_.blue; 
        green = c_.green; 
        alpha = c_.alpha; 
        return *this;
    }
    void HueSatVal(Float32 h, Float32 s, Float32 l);  
};
#define ColorRGBAMake(r,g,b,a) ColorRGBA((Float32)r,(Float32)g,(Float32)b,(Float32)a)
