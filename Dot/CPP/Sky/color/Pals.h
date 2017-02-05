
#import "Tr3.h"
#import "Pal.h"
#import "Ripple.h"
#import "Cycle.h"
#import "Rgbs.h"

#define RipMax 32
#define DynaMax 12
#define PresetMax 86 /* 17*5 +1 */
#define DynaRipMax 384 /* must always equal RipMax*DynaMax -- terrible kludge for static Hsvs */

struct Pix;
struct Pals {
	
    bool newPal;    // combined palette color ramps
    Rgbs rgbz;		// combined palette color ramps
    Rgbs final;		// final palette to render (after ripples and cycle)
  
    Tr3* bwOn;
    Tr3* bwVal;
    Tr3* xfade;    // cross fade between two current palettes
    Tr3* smooth;
    Tr3* insert;   // for adding color ramp to static pal
    Tr3* hue;      // triggers next ripple
    Tr3* sat;      // for next ripple
    Tr3* val;      // for next ripple
    
    Cycle  cycle;
    Ripple ripples[RipMax];
    int rips;
    int dyna;			// place holder for creating dynamic palette
	
    Hsv hsvs[RipMax];	// Hsvs for ripples
    Hsv dynaHsv[DynaRipMax];
    Pal* preset[PresetMax];
    Pal dynamic[DynaMax];
    
    int  flip;
     
    Rgbs colz;	// combined palette	color points
	
    Pal pal[2];
    Pal frac[2];
    Pal palBack[2];
    Pal tem;
    
    bool fractalized[2];
    
    Pals();
    
    void bindTr3(Tr3*root);
    void init(Tr3*root);
    void initPresets();
    Hsv* getHsvFromEnum(int num);
    Tr3CallbackEvent(Pals,palsShift);
    Tr3CallbackEvent(Pals,palsRipple);
    Tr3CallbackEvent(Pals,palsBack);
    Tr3CallbackEvent(Pals,palsFractal);

    void goFade();
    void goPal(); //public

    void setPal(Pal&);
    void dynaSet(int index);
    bool dynaAdd(int index);
};