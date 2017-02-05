#import "Univ.h"
#import <stdlib.h>
#import <stdio.h>
#import <memory.h>

Univ::Univ() {

    for (int i=0; i<FaceMax2; i++) {
		buf[i].buf=0;
    }
	bs	= 2;		// border
	bs2	= 2*bs;
    
    bufNext = &buf[0];   // this ignores FaceMax 
    bufPrev = &buf[1];   // this ignores FaceMax 
    
}
void Univ::init(Tr3*root, int xs_, int ys_) {
    
   wrap = root->bind("screen.face.univ.wrap");
    
    xs=xs_;
    ys=ys_;
    zs=4;
    xsb=xs+bs2;             // x size with left and right border
    ysb=ys+bs2;
    xy00=bs*xsb+bs;         // first element inside array;
                            // these next values are relative to beginning of array
    uSize	= xsb*ysb*zs;   // size of one int array with borders
    xsbOfs	= xsb*zs;       // size of one scanline of int array with borders
 
    
    for (int i=0; i<FaceMax2; i++) {
        
		buf[i].init(xsb,ysb,zs);
    }
	inow = 0;
	inext = inow+FaceMax; 
	getU(0,next,prev);
}
// these are the corners of the Universe
int *Univ::getNw(int*s) {return s;} 
int *Univ::getNe(int*s) {return s+(xs-1);}
int *Univ::getSe(int*s) {return s+(ys-1)*xsb+(xs-1);}
int *Univ::getSw(int*s) {return s+(ys-1)*xsb;}
void Univ::getSource(int*s, Edges edge, int*&s1, int*&s2, int&si, int &sMax){
	
    switch (edge) {
        case EdgeNeNw:	s1=getNe(s);	s2=s1+xsb;		si=  -1; sMax = xs; break;  
        case EdgeNwNe:	s1=getNw(s);	s2=s1+xsb;		si=   1; sMax = xs; break;  
            
        case EdgeSeSw:	s1=getSe(s);	s2=s1-xsb;		si=  -1; sMax = xs; break;  
        case EdgeSwSe:	s1=getSw(s);	s2=s1-xsb;		si=   1; sMax = xs; break;  
            
        case EdgeSwNw:	s1=getSw(s);	s2=s1+1;		si=-xsb; sMax = ys; break;  
        case EdgeNwSw:	s1=getNw(s);	s2=s1+1;		si= xsb; sMax = ys; break;  
            
        case EdgeSeNe:	s1=getSe(s);	s2=s1-1;		si=-xsb; sMax = ys; break;  
        case EdgeNeSe:	s1=getNe(s);	s2=s1-1;		si= xsb; sMax = ys; break;  
    }
}
void Univ::getDest(int*d, Edges edge, int*&d1, int*&d2, int&di, int &dMax){
	
    switch (edge) {
        case EdgeNeNw:	d1=getNe(d)-xsb;	d2=d1-xsb;	di=  -1; dMax = xs; break;  
        case EdgeNwNe:	d1=getNw(d)-xsb;	d2=d1-xsb;	di=   1; dMax = xs; break;  
            
        case EdgeSeSw:	d1=getSe(d)+xsb;	d2=d1+xsb;	di=  -1; dMax = xs; break;  
        case EdgeSwSe:	d1=getSw(d)+xsb;	d2=d1+xsb;	di=   1; dMax = xs; break;  
            
        case EdgeSwNw:	d1=getSw(d)-1;		d2=d1-1;	di=-xsb; dMax = ys; break;  
        case EdgeNwSw:	d1=getNw(d)-1;		d2=d1-1;	di= xsb; dMax = ys; break;  
            
        case EdgeSeNe:	d1=getSe(d)+1;		d2=d1+1;	di=-xsb; dMax = ys; break;  
        case EdgeNeSe:	d1=getNe(d)+1;		d2=d1+1;	di= xsb; dMax = ys; break;  
    }
}
void Univ::setBorderHoriz(int h, Edges edgeH,  int i, int j, Edges edgeJ) {// horizontal border
    
	int *tem;
	int *prevH;	getU(h,tem,prevH);	// pane to the left		
	int *prevI;	getU(i,tem,prevI);	// center pane
	int *prevJ;	getU(j,tem,prevJ);	// pane to the right
    
	int *ls1,*ls2,lsi,lsMax; // left source
	int *rs1,*rs2,rsi,rsMax; // right source
	int *ld1,*ld2,ldi,ldMax; // left dest
	int *rd1,*rd2,rdi,rdMax; // right dest
    
	getSource(prevH,edgeH,	 ls1,ls2,lsi,lsMax);	// 2 left  source lines with increment
	getSource(prevJ,edgeJ,	 rs1,rs2,rsi,rsMax);	// 2 right source lines with increment
	getDest	 (prevI,EdgeNwSw,ld1,ld2,ldi,ldMax);	// 2 left  destination lines with  increment
	getDest	 (prevI,EdgeNeSe,rd1,rd2,rdi,rdMax);	// 2 right destination lines with increment
    
	int yMax = ys;
	yMax = MIN(yMax,lsMax);
	yMax = MIN(yMax,rsMax);
	yMax = MIN(yMax,ldMax);
	yMax = MIN(yMax,rdMax);
    
	for (int y=0; y<yMax; y++) {
        
		*ld1 = *ls1; ld1+=ldi; ls1+=lsi;
		*ld2 = *ls2; ld2+=ldi; ls2+=lsi;
		*rd1 = *rs1; rd1+=rdi; rs1+=rsi;
		*rd2 = *rs2; rd2+=rdi; rs2+=rsi;
    }
}
void Univ::setBorderVerti(int h, Edges edgeH,  int i, int j, Edges edgeJ) { // vertical border
    
	int *tem;
	int *prevH;	getU(h,tem,prevH);	// pane above		
	int *prevI;	getU(i,tem,prevI);	// center pane
	int *prevJ;	getU(j,tem,prevJ);	// pane below
    
	int *as1,*as2,asi,asMax; // left source
	int *bs1,*bs2,bsi,bsMax; // right source
	int *ad1,*ad2,adi,adMax; // left dest
	int *bd1,*bd2,bdi,bdMax; // right dest
    
	getSource(prevH,edgeH,	 as1,as2,asi,asMax);	// 2 above source lines with increment	
	getSource(prevJ,edgeJ,	 bs1,bs2,bsi,bsMax);	// 2 below source lines with increment
	getDest	 (prevI,EdgeNwNe,ad1,ad2,adi,adMax);	// 2 above destination lines with  increment
	getDest	 (prevI,EdgeSwSe,bd1,bd2,bdi,bdMax);	// 2 below destination lines with increment
	
	int xMax = xs;
	xMax = MIN(xMax,asMax);
	xMax = MIN(xMax,bsMax);
	xMax = MIN(xMax,adMax);
	xMax = MIN(xMax,bdMax);
    
	for (int x=0; x<xMax; x++) {
        
		*ad1 = *as1;	ad1+=adi; as1+=asi;
		*ad2 = *as2;	ad2+=adi; as2+=asi;
		*bd1 = *bs1;	bd1+=bdi; bs1+=bsi;
		*bd2 = *bs2;	bd2+=bdi; bs2+=bsi;
    }
}
void Univ::GoSwap(GoVect goDst, GoVect goSrc, int *v1, int *v2){
	int goSrcLo = goSrc & 0x0F; 
	int goDstLo = goDst & 0x0F;
    
	int goSrcHi = goSrc & 0xF0;
	int goDstHi = goDst & 0xF0;
    
	int notDst = -1 ^ (int)goDst;
	int vd,vs;
	
	vs = *v1;
	vd  =   ((vs & notDst) |
             ((vs & goSrcLo) ? goDstLo : 0) |
             ((vs & goSrcHi) ? goDstHi : 0)); 
	*v1 = vd;
	
	vs = *v2;
	vd  =   ((vs & notDst) |
             ((vs & goSrcLo) ? goDstLo : 0) |
             ((vs & goSrcHi) ? goDstHi : 0)); 
	*v2 = vd;
}
void Univ::setBorderHorizSlider(int h, Edges edgeH,  int i, int j, Edges edgeJ) { // horizontal border
    
	int *tem;
	int *prevH;	getU(h,tem,prevH);	// pane to the left		
	int *prevI;	getU(i,tem,prevI);	// center pane
	int *prevJ;	getU(j,tem,prevJ);	// pane to the right
    
	int *ls1,*ls2,lsi,lsMax; // left source
	int *rs1,*rs2,rsi,rsMax; // right source
	int *ld1,*ld2,ldi,ldMax; // left dest
	int *rd1,*rd2,rdi,rdMax; // right dest
    
	getSource(prevH,edgeH,	 ls1,ls2,lsi,lsMax);	// 2 left  source lines with increment
	getSource(prevJ,edgeJ,	 rs1,rs2,rsi,rsMax);	// 2 right source lines with increment
	getDest	 (prevI,EdgeNwSw,ld1,ld2,ldi,ldMax);	// 2 left  destination lines with  increment
	getDest	 (prevI,EdgeNeSe,rd1,rd2,rdi,rdMax);	// 2 right destination lines with increment
    
	int yMax = ys;
	yMax = MIN(yMax,lsMax);
	yMax = MIN(yMax,rsMax);
	yMax = MIN(yMax,ldMax);
	yMax = MIN(yMax,rdMax);
    
	for (int y=0; y<yMax; y++) {
        
		*ld1 = *ls1; 
		*ld2 = *ls2; 
		*rd1 = *rs1; 
		*rd2 = *rs2; 
        
		switch (edgeH) {
            
            case EdgeNwNe:  case EdgeNeNw:	GoSwap(GoRight,GoUp   ,ld1,ld2);	break;  
            case EdgeSwSe:  case EdgeSeSw:	GoSwap(GoRight,GoDown ,ld1,ld2);	break;  
            case EdgeNeSe:  case EdgeSeNe:										break;  
            case EdgeNwSw:  case EdgeSwNw:	GoSwap(GoRight,GoLeft ,ld1,ld2);	break;  
        }
        
		switch (edgeJ) {
            
            case EdgeNwNe:  case EdgeNeNw:	GoSwap(GoLeft,GoUp	 ,rd1,rd2);		break;  
            case EdgeSwSe:  case EdgeSeSw:	GoSwap(GoLeft,GoDown ,rd1,rd2);		break;  
            case EdgeNeSe:  case EdgeSeNe:	GoSwap(GoLeft,GoRight,rd1,rd2);		break;  
            case EdgeNwSw:  case EdgeSwNw:										break;  
        }
		ld1+=ldi; ls1+=lsi;
		ld2+=ldi; ls2+=lsi;
		rd1+=rdi; rs1+=rsi;
		rd2+=rdi; rs2+=rsi;
    }
}
void Univ::setBorderVertiSlider(int h, Edges edgeH,  int i, int j, Edges edgeJ) { // vertical border
    
	int *tem;
	int *prevH;	getU(h,tem,prevH);	// pane above		
	int *prevI;	getU(i,tem,prevI);	// center pane
	int *prevJ;	getU(j,tem,prevJ);	// pane below
    
	int *as1,*as2,asi,asMax; // left source
	int *bs1,*bs2,bsi,bsMax; // right source
	int *ad1,*ad2,adi,adMax; // left dest
	int *bd1,*bd2,bdi,bdMax; // right dest
    
	getSource(prevH,edgeH,	 as1,as2,asi,asMax);	// 2 above source lines with increment	
	getSource(prevJ,edgeJ,	 bs1,bs2,bsi,bsMax);	// 2 below source lines with increment
	getDest	 (prevI,EdgeNwNe,ad1,ad2,adi,adMax);	// 2 above destination lines with  increment
	getDest	 (prevI,EdgeSwSe,bd1,bd2,bdi,bdMax);	// 2 below destination lines with increment
	
	int xMax = xs;
	xMax = MIN(xMax,asMax);
	xMax = MIN(xMax,bsMax);
	xMax = MIN(xMax,adMax);
	xMax = MIN(xMax,bdMax);
    
	for (int x=0; x<xMax; x++) {
        
		*ad1 = *as1;	
		*ad2 = *as2;	
		*bd1 = *bs1;	
		*bd2 = *bs2;	
        
		switch (edgeH) {
                
            case EdgeNwNe:  case EdgeNeNw:	GoSwap(GoDown,GoUp   ,ad1,ad2);	break;  
            case EdgeSwSe:  case EdgeSeSw:									break;  
            case EdgeNeSe:  case EdgeSeNe:	GoSwap(GoDown,GoRight,ad1,ad2);	break;  
            case EdgeNwSw:  case EdgeSwNw:	GoSwap(GoDown,GoLeft ,ad1,ad2);	break;  
        }
		switch (edgeJ) {
                
            case EdgeNwNe:  case EdgeNeNw:									break;  
            case EdgeSwSe:  case EdgeSeSw:	GoSwap(GoUp,GoDown ,bd1,bd2);	break;  
            case EdgeNeSe:  case EdgeSeNe:	GoSwap(GoUp,GoRight,bd1,bd2);	break;  
            case EdgeNwSw:  case EdgeSwNw:	GoSwap(GoUp,GoLeft ,bd1,bd2);	break;  
        }
		ad1+=adi; as1+=asi;
		ad2+=adi; as2+=asi;
		bd1+=bdi; bs1+=bsi;
		bd2+=bdi; bs2+=bsi;
    }
}
int *Univ::pxy(int i, int x, int y) { // pointer 
    
	return ( (int*)(buf[inow+i].buf) + xy00 + y*xsb + x);
}
void Univ::setCorners(int i) {
    
	for (int y=0; y<bs; y++) {		
     
        for(int x=0; x<bs; x++) {

                  int nwx = -1-x; int nwy = -1-y; int nwx1 = 0+x;		
                  int nex = xs+x; int ney = -1-y; int nex1 = xs-1-x;	
                  int swx = -1-x; int swy = ys+y; int swx1 = 0+x;		
                  int sex = xs+x; int sey = ys+y; int sex1 = xs-1-x;	
                  
            *pxy(i,nwx,nwy) = *pxy(i,nwx1,nwy); // +  *pxy(i,nwx,nwy1))/2;	// top left corner
            *pxy(i,nex,ney) = *pxy(i,nex1,ney); // +  *pxy(i,nex,ney1))/2;	// bottom left corner/
            *pxy(i,swx,swy) = *pxy(i,swx1,swy); // +  *pxy(i,swx,swy1))/2;	// top right corner
            *pxy(i,sex,sey) = *pxy(i,sex1,sey); // +  *pxy(i,sex,sey1))/2;	// bottom right corner
		}
    }
}
void Univ::setBorderLeftRight(int i) { // horizontal repeat
    
	int xsi = xsb-bs;		// scanline increment (after copy increment pointer by bs elements)
	int * lDst = (int*)(buf[inow+i].buf)+bs*xsb;	// skip vertical border scanlines	
	int * lSrc = lDst+bs;						
	int * rSrc = lDst+xs;	
	int * rDst = rSrc+bs;
    
	for (int y=0; y<ys; y++, lSrc+=xsi,lDst+=xsi,rSrc+=xsi,rDst+=xsi) {
        
        for(int b=0; b<bs; b++, lSrc++,  lDst++,  rSrc++,  rDst++) {
        
            *lDst=*rSrc;
            *rDst=*lSrc;
        }
    }
}
void Univ::setBorderLeftLeft(int i) { // horizontal mirror
    
	int * lDst = (int*)(buf[inow+i].buf)+bs*xsb;		
	int * lSrc = lDst+bs2-1;
	int * rSrc = lDst+xs;	
	int * rDst = rSrc+bs;
    
	for (int y=0; y<ys; y++, lSrc+=(xsb+bs),lDst+=(xsb-bs),	rSrc+=(xsb-bs),	rDst+=(xsb+bs)) {
        
        for(int b=0; b<bs; b++, lSrc--,		lDst++,			rSrc++,			rDst--) {
        
            *lDst=*lSrc;
            *rDst=*rSrc;
        }
    }
}
void Univ::setBorderTopBottom(int i) { // vertical repeat
    
	int *tDst = (int*)(buf[inow+i].buf);		
	int *tSrc = (int*)(buf[inow+i].buf)+bs*xsb;		
	int *bSrc = (int*)(buf[inow+i].buf)+ys*xsb;		
	int *bDst = bSrc+bs*xsb;	
    
	for (int z=0; z<xsb*bs; z++,tSrc++,tDst++,bSrc++,bDst++) {
		
        *tDst=*bSrc;
		*bDst=*tSrc;
    }
}
void Univ::setBorderTopTop(int i) { // vertical mirror
    
	int *tDst = (int*)(buf[inow+i].buf);				// first scanline of border
	int *tSrc = (int*)(buf[inow+i].buf)+(bs2-1)*xsb;	// last scanline of image border		
	int *bDst = (int*)(buf[inow+i].buf)+(ys+bs)*xsb;	// first scanline of bot border
	int *bSrc = (int*)(buf[inow+i].buf)+(ys+bs-1)*xsb;// last scanline of bottom image
	
	int yy,xx;
	for (yy=0; yy<bs;  yy++, tSrc -=(2*xsb)) { // got start of previous scanline
        
        for(xx=0; xx<xsb; xx++, tSrc ++, tDst++) {
        
            *tDst = *tSrc; 
        }
    }
	for (yy=0; yy<bs;  yy++, bSrc-=(2*xsb)) { // goto start of previous scanline
        
        for(xx=0; xx<xsb; xx++, bSrc++, bDst++) {
            
            *bDst = *bSrc;
        }
    }
}
void Univ::setBorderBlank(int i) { // clear out
    
	int xsi = xsb-bs;		// scanline increment (after copy increment pointer by bs elements)
	int * now  = (int*)(buf[inow+i].buf);
	int * top  = now+bs*xsb; // first scanline past upper border
	int * lDst = top;		
	int * lSrc = lDst+bs;
	int * rSrc = lDst+xs;	
	int * rDst = rSrc+bs;
    
	for (int y=0; y<ys; y++, lSrc+=xsi,lDst+=xsi,rSrc+=xsi,rDst+=xsi) {
        
        for(int b=0; b<bs; b++, lSrc++,  lDst++,  rSrc++,  rDst++) {
        
            *lDst=0;
            *rDst=0;
        }
    }
	int * tDst = (int*)(buf[inow+i].buf);		
	int * tSrc = top;		
	int * bSrc = tDst+ys*xsb;		
	int * bDst = bSrc+bs*xsb;	
    
	for (int z=0; z<xsb*bs; z++,tSrc++,tDst++,bSrc++,bDst++) {
        
		*tDst=0;
		*bDst=0;
    }
}
void Univ::setBorder(FaceMap&facemap){
    
    for (int i=0; i<facemap.univSurfs; i++) {
        
		if (!*wrap) {
			setBorderBlank(i);
        }
		else switch (facemap.faceMapType) {
                
			case Cube1All:
                
                setBorderLeftLeft(i);
                setBorderTopTop(i);
                break;
                
			case FacePlane:	
			case Cube1MirrorQ:
			case Cube1FrontQ:
#if 0
                // this was set to one before porting to iPhone, not sure if this for supporting cubemap or sliding universe, 
                // for 2d map, this interferes at the corners for Fredkin
                
                setBorderHorizSlider(i,EdgeNeSe,	i,	i,EdgeNwSw);
                setBorderVertiSlider(i,EdgeSwSe,	i,	i,EdgeNwNe);
                setCorners	  (i);
#else
                setBorderLeftRight(i);
                setBorderTopBottom(i);
                /// setCorners	  (i);
#endif
                break;
			case Cube6Unique:
                
                setBorderSlider(); return;
                
                setBorderHoriz(CubeLeft,	EdgeNeSe,	CubeFront,	CubeRight,	EdgeNwSw);
                setBorderHoriz(CubeFront,	EdgeNeSe,	CubeRight,	CubeBack,	EdgeNwSw);
                setBorderHoriz(CubeRight,	EdgeNeSe,	CubeBack,	CubeLeft,	EdgeNwSw);
                setBorderHoriz(CubeBack,	EdgeNeSe,	CubeLeft,	CubeFront,	EdgeNwSw);
                
                setBorderHoriz(CubeLeft,	EdgeNwNe,	CubeTop,	CubeRight,	EdgeNeNw);
                setBorderHoriz(CubeLeft,	EdgeSeSw,	CubeBottom,	CubeRight,	EdgeSwSe);
                
                setBorderVerti(CubeTop,		EdgeSwSe,	CubeFront,	CubeBottom,	EdgeNwNe);
                setBorderVerti(CubeTop,		EdgeSeNe,	CubeRight,	CubeBottom,	EdgeNeSe);
                setBorderVerti(CubeTop,		EdgeNeNw,	CubeBack,	CubeBottom,	EdgeSeSw);
                setBorderVerti(CubeTop,		EdgeNwSw,	CubeLeft,	CubeBottom,	EdgeSwNw);
                
                setBorderVerti(CubeBack,	EdgeNeNw,	CubeTop,	CubeFront,	EdgeNwNe);
                setBorderVerti(CubeFront,	EdgeSwSe,	CubeBottom,	CubeBack,	EdgeSeSw);
                
                setCorners(CubeRight);
                setCorners(CubeLeft);
                setCorners(CubeTop);
                setCorners(CubeBottom);
                setCorners(CubeFront);
                setCorners(CubeBack);
				
                return;
			default: break;
        }
    }
}
void Univ::setBorderSlider() {
	setBorderHorizSlider(CubeLeft,	EdgeNeSe,	CubeFront,	CubeRight,	EdgeNwSw);
	setBorderHorizSlider(CubeFront,	EdgeNeSe,	CubeRight,	CubeBack,	EdgeNwSw);
	setBorderHorizSlider(CubeRight,	EdgeNeSe,	CubeBack,	CubeLeft,	EdgeNwSw);
	setBorderHorizSlider(CubeBack,	EdgeNeSe,	CubeLeft,	CubeFront,	EdgeNwSw);
    
	setBorderHorizSlider(CubeLeft,	EdgeNwNe,	CubeTop,	CubeRight,	EdgeNeNw);
	setBorderHorizSlider(CubeLeft,	EdgeSeSw,	CubeBottom,	CubeRight,	EdgeSwSe);
    
	setBorderVertiSlider(CubeTop,	EdgeSwSe,	CubeFront,	CubeBottom,	EdgeNwNe);
	setBorderVertiSlider(CubeTop,	EdgeSeNe,	CubeRight,	CubeBottom,	EdgeNeSe);
	setBorderVertiSlider(CubeTop,	EdgeNeNw,	CubeBack,	CubeBottom,	EdgeSeSw);
	setBorderVertiSlider(CubeTop,	EdgeNwSw,	CubeLeft,	CubeBottom,	EdgeSwNw);
    
	setBorderVertiSlider(CubeBack,	EdgeNeNw,	CubeTop,	CubeFront,	EdgeNwNe);
	setBorderVertiSlider(CubeFront,	EdgeSwSe,	CubeBottom,	CubeBack,	EdgeSeSw);
    
}

#define NextR	 int r2  = 255-r1;\
int r3  = (hc+(r1&0x3));\
int r  = (r3<<16) | (r2<<8) | r1;\
changed |= *next^r;\
*next = r; 

#define ForXYR(f) ForXY { int r1 = (f); NextR } break;

void Univ::set(int fill) {
    
 	void *now = ((void*)(int*)(buf[inow].buf));				// first real scanline below border
	memset (now,sizeof(int)*uSize,fill);
}
void Univ::copyFromPrev(int *dst,int yys, int xxs) {
    
	int xsi = xs+bs2-xxs; // offset to wrap from end of line to begin of next line
    int *src = getPrev();
	for (int y=0; y < yys; y++, src+=xsi) {
        
        for (int x=0; x < xxs; x++, src++,  dst++ ) {
            
			*dst = *src;
        }
    }
}
void Univ::copyFromMix(int *dst,Mix &mix) {

    int xxs = mix.buf->xs;
    int yys = mix.buf->ys;
    
	int xsi = xs+bs2-xxs; // offset to wrap from end of line to begin of next line
    int *src = getNext();
    byte *mx = mix.buf[0].buf;
    
	for (int y=0; y < yys; y++, src+=xsi) {
        
        for (int x=0; x < xxs; x++, src++,  mx++, dst++ ) {
            
			*dst = (*src & 0xFFFFFF00) | (*mx &0xFF);
        }				
    }
}
void inline Univ::copyUniv(int *dst, int *src, int yys, int xxs) {
    
	int xsi = xs+bs2-xxs; // offset to wrap from end of line to begin of next line 
    
	for   (int y=0; y < yys; y++, src+=xsi, dst+=xsi) {
        
        for (int x=0; x < xxs; x++, src++	 ,  dst++ ) { 
            
			*dst = *src;
        }				
    }
}
void inline Univ::zeroUniv(int *dst, int yys, int xxs) {			

	int xsi = xs+bs2-xxs; // offset to wrap from end of line to begin of next line 
    
	for   (int y=0; y < yys; y++, dst+=xsi)	{
        
        for (int x=0; x < xxs; x++, dst++ ) { 
	
            *dst = 0;
        }
    }
}
void Univ::copyLeft(int left, int right, int xx) {
    
	int *dstL,*dstR,
    *srcL,*srcR;
	
	getU(left, dstL,srcL);
	getU(right,dstR,srcR);
    
	bool wrapped = *wrap;
    
    /**/         copyUniv(dstL+0,     srcL+xx,	ys, xs-xx);
	if (wrapped) copyUniv(dstL+xs-xx, srcR+0,	ys,	xx);
	else 		 zeroUniv(dstL+xs-xx,			ys, xx);
}
void Univ::copyRight(int right, int left, int xx) {
	
    int *dstL,*dstR,*srcL,*srcR;
	
	getU(left, dstL,srcL);
	getU(right,dstR,srcR);
    
	bool wrapped = *wrap;
	
    /**/         copyUniv(dstR-xx, srcR,	 		ys,	 xs+xx); // xx < 0
 	if (wrapped) copyUniv(dstR+0,  srcL+xs+xx,	ys, -xx);
	else		 zeroUniv(dstR+0,					ys, -xx);
}
void Univ::copyDown(int dn, int up, int yy) {
    
	int *dstU,*dstD, *srcU,*srcD;
	
	getU(up,dstU,srcU);
	getU(dn,dstD,srcD);
    
	bool wrapped = *wrap;
    // yy < 0
    /**/         copyUniv(dstD-yy*xsb, srcD+0,		  ys+yy, xs);
	if (wrapped) copyUniv(dstD+0,	     srcU+(ys+yy)*xsb, 	-yy, xs);
	else 		 zeroUniv(dstD+0,							-yy, xs);
}
void Univ::copyUp(int up, int dn, int yy) {

	int *dstU,*dstD, *srcU,*srcD;
	
	getU(up,dstU,srcU);
	getU(dn,dstD,srcD);
    
	bool wrapped = *wrap;
	
    /**/         copyUniv(dstU+0,			srcU+yy*xsb,ys-yy, xs);
	if (wrapped) copyUniv(dstU+(ys-yy)*xsb, srcD+0,		   yy, xs);
	else 		 zeroUniv(dstU+(ys-yy)*xsb,				   yy, xs);
}
void Univ::setShiftCubeUnique(int x, int y) {
    
    int xx = (-x)%xs;
	int yy = (-y)%ys;
    
	if (xx>0) {
        
        copyLeft(CubeLeft,	CubeFront,	xx);
        copyLeft(CubeFront, CubeRight,	xx);
        copyLeft(CubeRight, CubeBack,	xx);
        copyLeft(CubeBack,	CubeLeft,	xx);
        
        copyLeft(CubeTop,	CubeTop,	 xx);
        copyLeft(CubeBottom,CubeBottom,	 xx);
    }
	else if (xx<=0) {
        
        copyRight(CubeRight,CubeFront,	xx);
        copyRight(CubeBack,	CubeRight,	xx);
        copyRight(CubeLeft,	CubeBack,	xx);
        copyRight(CubeFront,CubeLeft,	xx);
        
        copyRight(CubeTop,	 CubeTop,	xx);
        copyRight(CubeBottom,CubeBottom,xx);
        
    }
    nextU();
    
	if (yy>0) {
         
        copyUp(CubeLeft,	CubeLeft,	yy);
        copyUp(CubeFront,	CubeFront,	yy);
        copyUp(CubeRight,	CubeRight,	yy);
        copyUp(CubeBack,	CubeBack,	yy);
        
        copyUp(CubeTop,		CubeFront,	 yy);
        copyUp(CubeBottom,	CubeBottom,	  0);
    }
	else if (yy<0) {
        
        copyDown(CubeLeft,	CubeLeft,	yy);
        copyDown(CubeFront,	CubeFront,	yy);
        copyDown(CubeRight,	CubeRight,	yy);
        copyDown(CubeBack,	CubeBack,	yy);
        
        copyDown(CubeTop,   CubeTop,	 0);
        copyDown(CubeBottom,CubeFront,	yy);
    }
    nextU();
 }
void Univ::setShift(FaceMap &facemap, int x, int y) {
    
	if (facemap.faceMapType==Cube6Unique) {
        setShiftCubeUnique(x,y);
    }
    
    int xx = (-x)%xs;
	int yy = (-y)%ys;
	int i;
    
    nextU();
    
    if (xx==0 && yy==0) {

        return;
    }
	if (xx>0) {
        
        for (i=0; i<facemap.univSurfs; i++) {
            copyLeft(i,i,xx);
        }
    }
	else if (xx<=0) {
        
        for (i=0; i<facemap.univSurfs; i++) {
            copyRight(i,i,xx);
        }
    }
    nextU(); 
    
    if (yy>0) {
        
        for (i=0; i<facemap.univSurfs; i++) {
            copyUp(i,i,yy);
        }
    }
	else if (yy<=0) {
        
        for (i=0; i<facemap.univSurfs; i++) {
            copyDown(i,i,yy);
        }
    }
    nextU(); 
}
void Univ::go(FaceMap&facemap) {
    
	setBorder(facemap);
}
void Univ::nextU() { // setup prev and next 
    
	int temp = inext;
	inext	 = inow;
	inow	 = temp;
}
void Univ::getU(int i,int*&gnext, int*&gprev) { // setup prev and next 
    
    bufPrev = &buf[inow  + i];
    bufNext = &buf[inext + i];
    next = (int*)(bufNext->buf)+xy00;
	prev = (int*)(bufPrev->buf)+xy00;
	gnext = next;
	gprev = prev;
}
int *Univ::getPrev() {
    
    Buf *bPrev = &buf[inow];
    int *gPrev = (int*)(bPrev->buf)+xy00;
    return gPrev;
}
int *Univ::getNext() {
    Buf *bNext = &buf[inow];
    int *gNext = (int*)(bNext->buf)+xy00;
    return gNext;
}
int Univ::uxyOfs(int x, int y) {
    return  y*xsb + x;
}
int &Univ::uxy(int x, int y) {
    return *(int*)(bufNext->getXYP(x,y)); 
}
int &Univ::uxyp(int x, int y) {
	return *(prev + y*xsb + x);
}
Univ::~Univ() {
}


