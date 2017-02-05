#import "../main/SkyDefs.h"
#import "Buf.h"
#import "CellRules.h"
#import "Univ.h"
#import "Mix.h"
#import "Pix.h"
#import "FaceMap.h"
#import "Shift.h"

typedef enum {
    kVisualsReal, // rgba  color mapped
    kVisualsFake, // false color mapped
    kVisualsMax, // always last
} VisualsType;

struct Pic {   
    
    Buf	buf32;           // pixel buffer
    
    FaceMap facemap;	// number of surfaces of 2D plane or cube	
    Shift shift[kVisualsMax];
    Univ univ;		// setup new universe for next rule cycle
    Mix mix;		// mix new universe into viewable surface
    Pix pix;		// setup direct draw and gdi client areas
    CellRules* rules;    // transform old universe into new one
    
    int xs,ys,zs;       // x,y size and byte depth
    
    Pic(){}
    void init(Tr3*root, void* src, int xs, int ys, int zs);
    void copyDataToUniv(void* src);
    void copyByteToMonoUniv(void*src,int offset);
    void copyRgbaToMonoUniv(void*src,bool fromZero);
    void copyRgbaToMonoUniv(void*src,int sourceXs, int sourceYs, bool fromZero, FlipType flipType);
    void* getWin();
    
    void goPic(); //public
    void goRule();
    void go8();
    void goPixelBuffer(void*pixelBuffer);
};



