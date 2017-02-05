
#import "../main/SkyDefs.h"
#import "../main/SkyDefs.h"

typedef struct { 
	byte r;
	byte g;
	byte b; // 0..255
	byte a;	// not used
}   Rgb;

typedef struct {
	unt h;	// 0..359
	unt s;	// 0..100
	unt v;	// 0..100
} Hsv;

typedef enum {
	Irgb=0, // red to yellow h:0..59
	Igrb=1,	// yellow to green h:60..119
	Igbr=2,	// green to cyan
	Ibgr=3,	// cyan to blue
	Ibrg=4,	// blue to magenta
	Irbg=5,	// magenta to red
} RgbSort;

typedef enum {
	NoSplice=0,
	Left	=1,
	Right	=2,
	Both	=3,	// (SpliceLeft+SpliceRight
} Splice;

struct Rgbs;	// really a friend class -- circular reference

struct Colors {
    
    Hsv* _hsvArray;     // Hsv color Point array
    Rgb* _rgbArray;		// Rgb color Point array 
    int* _sizeArray;		// Size of ramp  array
    int _colorNow;	// next available slot in array
    int _colorSize;	// size of array
    Splice _splice; // how to join this color set with others
    
    Colors(Splice newSplice=Both);
    
    void init (Rgb, Rgb); // construct colors with initial ramp
    void init (Hsv, Hsv); // construct colors with inital ramp
    
    int inline	between (int,int,int,int);
    Hsv &		rgb2hsv (Rgb&);
    static Rgb &hsv2rgb (Hsv);
    
    Hsv &middle(Hsv  &p,	Hsv &q);
    bool ramps (Rgbs &q, int val);
    bool resizeColors (int i);
    
    Hsv & last();
    Hsv & first();
    void setColors(Colors&);	
    bool addRgb(Rgb i);	
    bool addHsv(Hsv i);	
    bool addColors(Colors&);	
};