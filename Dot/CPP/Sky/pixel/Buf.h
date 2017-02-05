#import "../main/SkyDefs.h"
#import <stdint.h>
typedef enum {

    kFlipNone,
    kFlipHorizontal,
    kFlipVertical,
    kFlipVertiHoriz,
    kFlipBoth,
    kFlipClockwise,   
    kFlipCounter,
    kFlipClockwiseHoriz,   
    kFlipCounterHoriz,
    
 } 
    FlipType;

struct Buf {
    
    int32_t	xs,ys,zs;			// dimensions of pixel surface
    int32_t xzs;				// size of scanline
    int32_t xyzs;				// size of pixel surface
    byte* buf;                  // pointer to surface
    
    int32_t srcX, srcY;			// starting source position
    int32_t dstX, dstY;			// starting destination position
    int32_t endX, endY;			// ending destination position
    
    int32_t srcSkipX, srcSkipY;	// skip row and column for source
    int32_t dstSkipX, dstSkipY;	// skip row and column for destination
     
    int32_t copyXs,copyYs;		// x and y sizes to copy
    
    Buf();
    ~Buf();
    
    void clear		  ();
    bool reInit		  ();
    bool init		  (	int32_t xs_, int32_t ys_, int32_t zs_);
    void setP         ( void*p_);
    
    unsigned int* xOfs;      // precompute line offsets to eliminate innerloop multiplys
    unsigned int* yOfs;      // precompute row offsets to eliminate innerloop multiplys
    bool initOfs(int xi,int yi); // init xOfs yOfs with offset xi, yi
    void* getXYP(int x, int y);  // return offsetted position within p
    
    inline void setup	   (int srcXs, int srcYs, int srcZs);
    inline void setup2	   (int srcXs, int srcYs, int srcZs); // for mirrored copy

    bool fill		  (	unt rgb);
    bool copyByteToMono(byte*src,int srcXs, int srcYs, int offset);    
    bool copyRgbaToMono(byte*src,int srcXs, int srcYs, bool fromZero, FlipType flipType);    
    bool copy		  (	byte*src,int srcXs, int srcYs, int srcZs);
    bool copyFlip	  (	byte*src,int srcXs, int srcYs, int srcZs);
    bool copyMirror	  (	byte*src,int srcXs, int srcYs, int srcZs);
    bool copyFlipMirror(byte*src,int srcXs, int srcYs, int srcZs);
    
    bool copyFlipUp	  (	byte*src,int srcXs, int srcYs, int srcZs);
    bool copyFlipMirUp( byte*src,int srcXs, int srcYs, int srcZs);
    
    bool copyShift	  (	bool flip,
                       byte*src,int srcXs, int srcYs, int srcZs,
                       int shiftX, int shiftY);
    
    bool copyShift	  (	byte*src,int srcXs, int srcYs, int srcZs,
                       int shiftX, int shiftY);
    
    bool copyShiftFlip(	byte*src,int srcXs, int srcYs, int srcZs,
                       int shiftX, int shiftY);
    
    bool copy(bool flip,
              Buf& srcPix,
              int srcX,	int srcY, 
              int dstX,	int dstY,
              int copyXs, int copyYs);
    
    bool copy(bool flip,
              byte*s,int srcXs,int srcYs,int srcZs, 
              int srcX,	int srcY, 
              int dstX,	int dstY,
              int copyXs, int copyYs);
    
    bool copyFlip(byte*s,int srcXs,int srcYs,int srcZs, 
                  int srcX,	int srcY, 
                  int dstX,	int dstY,
                  int copyXs, int copyYs) ;
    
    
    bool copy8(byte*s,int srcXs,int srcYs,int srcZs, 
               int srcX,	int srcY, 
               int dstX,	int dstY,
               int copyXs, int copyYs);
    
    bool copy(byte*s,int srcXs,int srcYs,int srcZs, 
              int srcX,	int srcY, 
              int dstX,	int dstY,
              int copyXs, int copyYs);
};