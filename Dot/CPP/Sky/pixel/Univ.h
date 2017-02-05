#import "Tr3.h"
#import "../main/SkyDefs.h"
#import "../pixel/Buf.h"
#import "../pixel/FaceDefs.h"
#import "../pixel/FaceMap.h"
#import "Mix.h"

typedef enum {
    
	GoDown = (1 | 16),
	GoUp   = (2 | 32),
	GoLeft = (4 | 64),
	GoRight= (8 |128)
} 
GoVect; // used by setBorderSlider

struct Univ {
    
    int x,y;		// current coord
    int xs,ys,zs;	// size of pixel array
    int bs;			// border size
    int bs2;		// double border size -- skip from end of current scanline to begining to next one
    int xb, yb;		// rendering border
    int	xsb,ysb;	// array diminsions with borders
    
    // these next values are relative to beginning of array
    
    int xy00;		// first element of array inside border -- offset in int elements
    int	uSize;		// size of each u[i] in bytes
    int uCount;		// number of u[] surfaces
    int	xsbOfs;		// size of one scanline of int array with borders
 
    Tr3*wrap;
    
    int inow;		// index to current    u[]
    int inext;		// index to next       u[]
    
    Buf buf[FaceMax2];	// up to two cube surfaces available
    Buf *bufPrev;
    Buf *bufNext;
    
    int *prev;			// previous surface with offset
    int *next;			// next surface with offset
    
    
    Univ ();
    ~Univ();
    void init	(Tr3*root, int newXs, int newYs);
    
    int uxyOfs (int x, int y);
    int &uxy (int x, int y);
    int &uxyp(int x, int y);
    int *pxy(int i, int x, int y); // pointer 
    
    void nextU();
    void getU(int,int*&gnext,int*&gprev);
    int *getPrev();
    int *getNext();
    void set (int fill);
    
    int *getNw(int*s); 
    int *getNe(int*s); 
    int *getSe(int*s); 
    int *getSw(int*s); 
    
    void getSource(int*s, Edges edge, int*&s1, int*&s2, int&si, int &sMax);
    void getDest  (int*d, Edges edge, int*&d1, int*&d2, int&di, int &dMax);
    
    void setBorderHoriz(int h, Edges edgeH, int i, 	int j, Edges edgeJ);
    void setBorderVerti(int h, Edges edgeH,	int i, 	int j, Edges edgeJ); 
    
    void setCorners(int i); 
    void setBorderLeftRight(int);
    void setBorderTopBottom(int);
    void setBorderLeftLeft(int);
    void setBorderTopTop(int);
    void setBorderBlank(int);
    void setBorder(FaceMap&);
    
    void GoSwap(GoVect, GoVect, int*, int*);
    void setBorderHorizSlider(int h, Edges edgeH, int i, int j, Edges edgeJ); 
    void setBorderVertiSlider(int h, Edges edgeH, int i, int j, Edges edgeJ); 
    
    void setBorderSlider();
    
    void copyFromMix(int *dst, Mix&mix);
    void copyFromPrev(int *dst, int yys, int xxs);
    void copyFromNext(int *dst, int yys, int xxs);
    void inline copyUniv(int *dst,	int *src,	 int yys, int xxs);
    void inline zeroUniv(int *dst,				 int yys, int xxs);
    
    void inline copyLeft (int dsti, int srci, int xx);
    void inline copyRight(int dsti, int srci, int xx);
    void inline copyUp	 (int dsti, int srci, int yy);
    void inline copyDown (int dsti, int srci, int yy);
    
    void setShiftCubeUnique(int x, int y);
    void setShift(FaceMap&, int xx, int yy);
    
    void go(FaceMap&);
};