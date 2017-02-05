#import "RgbDef.h"
#import "Tr3.h"
#import "../pixel/FaceMap.h"
#import "../color/Pal.h"
#import "../color/Pals.h"

#ifndef byte
#define byte unsigned char
#endif

struct Pix {
    
    void* buf[FaceMax];// texture map buffers, up to six for WinOg Cube map
    int   bufSize;	  // size of each buffer 
    int	  bufCount;   // number of buffers; ==1 for WinGdi, and WinDx
    
    void* palz;
    int   rgbPlanes; // last rendering bits per pixel
    int	  palPlanes;
    int	  planes;	 // new rendering bits per pixel
    
    bool  initialized;
    
    Tr3* realfake;
    Tr3* fadeReal;
    Tr3* fadeFake;
    Tr3* fadeCross;
    Tr3* lumaSize;
    Tr3* lumaBlack;
    Tr3* lumaWhite; 
    
    Pals pals;		// adjust current palette
    
    Pix();
    
    void bindTr3(Tr3*root);
    void init(Tr3*root, int zs);
    void goPix(FaceMap&,Buf&buf8,Buf&buf32);
    
    void bwPal();	// set default bw palette
    bool setPal();
    bool setBuf(FaceMap&,Buf&,Buf&);
    bool setBmp(void* buf, byte* pseudo);
    bool setBmp(void* buf, int* real);
    bool setBmp(void* buf, int* real, byte* pseudo);
    void setFade(bool&realist);
    void**rePlane(FaceMap&,Buf&,Buf&);
};
