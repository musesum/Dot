
#import "../main/SkyDefs.h"
#import "../color/PalAmount.h"
#import "../color/Colors.h"
#import "../color/Rgbs.h"
#import <deque>
#import "Tr3.h"

struct Pal;

typedef deque <Pal*> SubPals;

struct Pal {
    
    bool abstract;	// I don't have a local palette
    
    int       size;     // size of palette
    Rgbs      rgbs;     // my local palette
    Colors    colors;
    
    Pal ();
    Pal (bool abstract_);
    Pal (Rgb i, Rgb j); // construct palette with ramp
    Pal (Hsv i, Hsv j); // construct palette with ramp
    
    Pal (Rgb i, Rgb j, Rgb k); // construct palette with ramp
    Pal (Hsv i, Hsv j, Hsv k); // construct palette with ramp
    
    void renderSubPal(int size,int firstSizeExpand);
    void renderZenoPal(int size);
    void renderPal(int size);
    void renderColorRamp (int);
    
    SubPals subPals;
    void addPal(Pal&pal) {subPals.push_back(&pal);}
    
    // Node overides
    void setPal (Pal&);		
    bool copy (Pal&);		
    bool shift(Hsv&, bool insert=1); // add a new pal ramp from right
};