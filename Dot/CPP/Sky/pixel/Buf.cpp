#import "Buf.h"
#import <stdlib.h>
#import <stdio.h>
#import "../main/SkyDefs.h" 

Buf::Buf() {
    
	xs=0;
	ys=0;
	zs=0;
	buf = 0;
    xOfs = 0;
    yOfs = 0;
}   
void Buf::clear() {

	if (buf) {
		
        free(buf);
		buf=0;
    }
    if (xOfs) {
        
        free(xOfs);
        xOfs = 0;
    }
    if (yOfs) {
        
        free(yOfs);
        yOfs = 0;
    }
}
bool Buf::reInit() {

	clear();
	xzs = xs*zs;
	xyzs = xs*ys*zs;
	buf = (byte*)malloc(xyzs);
	if (buf) return true;
	return false;
}
void* Buf::getXYP(int x, int y) {

    return buf +yOfs[y] + xOfs[x];
}
void Buf::setP(void* p_) {

    buf = (byte*) p_;
}
bool Buf::initOfs(int xi,int yi) {

    if (xOfs) {
        free(xOfs);
    }
    xOfs = (unsigned int*)  malloc(xs*sizeof(unsigned int));
    if (!xOfs) {
        return false;
    }
    if (yOfs) {
        free(yOfs);
    }
    yOfs = (unsigned int*)  malloc(ys*sizeof(unsigned int));
    if (!yOfs) {
        return false;
    }
    int initialOffset = (yi * xi + xi);  // this is used by Univ which has a 1 pixel border around buffer  so a 320x480 univ is really 322x482, with a (1,1) offset
    
    int i;                                  
    for (i=0; i < ys; i++) {
        
        yOfs[i] = (i * xs + initialOffset)*zs;
    }

    for (i=0; i<xs; i++) {
        
        xOfs[i] = i*zs;
    }
    return true;
}
bool Buf::init(int xs_,int ys_, int zs_) {

    if (buf &&
        xs==xs_ &&
        ys==ys_ &&
        zs==zs_) {
        return true; // everthing is already initialized to same size 
    }
	clear();
	xs  = xs_;
	ys  = ys_;
	zs  = zs_;
	xzs = xs*zs;
	xyzs = xs*ys*zs;
	buf = (byte*)malloc(xyzs);
    
	if (buf && initOfs(0,0)) 
        return true;
	return false;
}

inline  void Buf::setup(int srcXs, int srcYs, int srcZs) {
    
	if (srcXs < xs) {
    
		srcSkipY	= 0;						
		dstSkipY	= (xs - srcXs)*zs;	
		srcX	= 0;
		dstX	= (xs - srcXs)/2;
		endX	=  dstX  + srcXs;
		copyXs  = srcXs;
    }
	else if (srcXs > xs) {
    
		srcSkipY = (srcXs-xs)*srcZs;	
		dstSkipY = 0;					
		srcX	= (srcXs-xs)/2;
		dstX	= 0;
		endX	= xs;
		copyXs  = xs;
    }
	else { 
		srcSkipY = 0;					
		dstSkipY = 0; 					
		srcX	= 0;
		dstX	= 0;
		endX	= srcXs;
		copyXs  = srcXs;
    }
    
	if (srcYs < ys) {
    
		srcY	= 0;
		dstY	= (ys - srcYs)/2;
		endY	= srcYs + dstY;
		copyYs  = srcYs;
    }
	else if (srcYs > ys) {
    
		srcY	= (srcYs - ys)/2;	
		dstY	= 0;	
		endY	= ys;
		copyYs  = ys;
    }
	else {
		srcY	= 0;
		dstY	= 0;
		endY	= srcYs;
		copyYs  = ys;
    }
}



inline void copyXz(byte*&dst,byte*&src,int xs, int z0s, int z1s, 
                   int di, int si, int xskip) {
	int x,z;
	for (	x=0; x<xs; x++, src+=xskip)	
    {
		for(z=0; z<z0s; z++, dst+=di,src+=si) 	*dst =  *src;
		for(z=0; z<z1s; z++, dst+=di)			*dst =  0;
    }
}
bool Buf::fill(unt rgb) {
	
	if (!buf) 
		return false;
    
	unt b = rgb &0xFF; rgb >>=8;
	unt g = rgb &0xFF; rgb >>=8;
	unt r = rgb &0xFF; 
    
	byte*  dst = buf;
	dstSkipY /= 4; // kludged resize from byte* to unt*
    
	if (zs==1)
    {
 		for	 (int y=0; y<ys; y++) 
            for (int x=0; x<xs; x++)	
            {
				*dst =  b&0xff; dst++;
            }
    }
 	else{
		for	 (int y=0; y<ys; y++) 
            for (int x=0; x<xs; x++)	
            {
				*dst =  r&0xff; dst++;
				*dst =  g&0xff; dst++;
				*dst =  b&0xff; dst++;
				if (zs==4)		dst++;
            }
    }
	return true;
}
bool Buf::copyByteToMono(byte*s,int srcXs, int srcYs, int offset) {
    
	if (!s || !buf) 
		return false;
    
	setup(srcXs,srcYs,4);
    
	byte* src =       s + ((srcY*srcXs)+srcX) * 4;
	unt*  dst = (unt*)buf + ((dstY*xs)+dstX);
	dstSkipY /= 4; // kludged resize from byte* to unt*
    
    for	(int y=dstY; y<endY; y++, dst+=dstSkipY,src+=srcSkipY) {
        
        for (int x=dstX; x<endX; x++, dst++, src+=4) {	
            
            *dst = src[offset];
            //if (x==y)fprintf(stderr, "(%i,%i,%i):%i ",src[0],src[1],src[2], *dst);
        }
    }    
	return true;
}

bool Buf::copyRgbaToMono(byte*s,int srcXs, int srcYs, bool fromZero, FlipType flipType) {
    
	if (!s || !buf) 
		return false;
    
    int tem;
    #define Flip(A,B) tem = A; A = B; B = tem;  
    
    byte* src;
    unt* dst;
    unt* d = (unt*)buf;
    
    setup(srcXs,srcYs,4);
    
    dstSkipY /= 4; // kludged resize from byte* to unt*    
    
    switch (flipType) {
            
        default:
        case kFlipNone:{
            
            int lines = endY-dstY;
            int rows = endX-dstX;       
            
            for	(int y=0; y<lines; y++) {
                
                src = s +((y+srcY) * srcXs  + srcX )* 4;
                dst = d +((y+dstY) * xs     + dstX );
                               
                for (int x=0; x<rows; x++, dst++, src+=4) {	
                    
                    *dst = (src[0]+src[1]+src[2])/3;
                }
            }    
            return true;
        }
        case kFlipClockwise: {
        
            Flip(dstX,dstY)
            Flip(endX,endY)
            
            int lines = endY-dstY;
            int rows  = endX-dstX;

            srcSkipX = srcXs*4;
            
            for	(int y=0; y<lines; y++) {
            
                int srcLine   = srcYs-1;
                int srcOffset = (srcLine*srcXs)  + srcX + y;
                int dstOffset = (y+dstY) * xs    + dstX;
                src           = s + srcOffset*4;
                dst           = d + dstOffset;
                               
                for (int x=0; x<rows; x++, dst++, src-=srcSkipX) {	
                    
                    *dst = (src[0]+src[1]+src[2])/3;
                }
            }    
            return true;
        }
       case kFlipClockwiseHoriz: {
        
            Flip(dstX,dstY)
            Flip(endX,endY)
            
            int lines = endY-dstY;
            int rows  = endX-dstX;

            srcSkipX = srcXs*4;
            
            for	(int y=0; y<lines; y++) {
            
                int srcLine   = 0;
                int srcOffset = (srcLine*srcXs)  + srcX + y;
                int dstOffset = (y+dstY) * xs    + dstX;
                src           = s + srcOffset*4;
                dst           = d + dstOffset;
                               
                for (int x=0; x<rows; x++, dst++, src+=srcSkipX) {	
                    
                    *dst = (src[0]+src[1]+src[2])/3;
                }
            }    
            return true;
        }
        case kFlipCounter: {
            
            int lines = endX-dstX;
            int rows  = endY-dstY;
            
            Flip(dstX,dstY)
            Flip(endX,endY)
            
            srcSkipX = srcXs*4;
            
            for	(int y=0; y<lines; y++) {
            
                int srcLine   = 0;
                int srcOffset = (srcLine*srcXs) + srcX + lines-y-1;
                int dstOffset = (y+dstY)*xs     + dstX;
                src           = s + srcOffset*4;
                dst           = d + dstOffset;
                               
                for (int x=0; x<rows; x++, dst++, src+=srcSkipX) {	
                    
                    *dst = (src[0]+src[1]+src[2])/3;
                }
            }    
            return true;
        }
        case kFlipCounterHoriz: {
            
            int lines = endX-dstX;
            int rows  = endY-dstY;
            
            Flip(dstX,dstY)
            Flip(endX,endY)
            
            srcSkipX = srcXs*4;
            
            for	(int y=0; y<lines; y++) {
            
                int srcLine   = srcYs-1;;
                int srcOffset = (srcLine*srcXs) + srcX + lines-y;
                int dstOffset = (y+dstY)*xs     + dstX;
                src           = s + srcOffset*4;
                dst           = d + dstOffset;
                               
                for (int x=0; x<rows; x++, dst++, src-=srcSkipX) {	
                    
                    *dst = (src[0]+src[1]+src[2])/3;
                }
            }    
            return true;
        }
        case kFlipHorizontal: {
            
            int lines = endY-dstY;
            int rows = endX-dstX;
            
            for (int y=0; y<lines; y++) {
            
                int srcLine     = y + srcY;
                int srcOffset   = srcLine  * srcXs  + srcX + xs-1;
                int dstOffset   = (y+dstY) * xs     + dstX ;
                src             = s +srcOffset*4;
                dst             = d +dstOffset;
                               
                for (int x=0; x<rows; x++, dst++, src-=4) {	
                    
                    *dst = (src[0]+src[1]+src[2])/3;
                }
            }    
            return true;
        }
        case kFlipVertical: {
            
            int lines = endY-dstY;
            int rows = endX-dstX;
            
            for	(int y=0; y<lines; y++) {
                
                src = s +(((lines-y-1)+srcY) * srcXs  + srcX )* 4;
                dst = d +((y+dstY)           * xs     + dstX );
                               
                for (int x=0; x<rows; x++, dst++, src+=4) {	
                    
                    *dst = (src[0]+src[1]+src[2])/3;
                }
            }    
        return true;
        }
        case kFlipVertiHoriz: {
            
            int lines = endY-dstY;
            int rows = endX-dstX;
            
            for (int y=0; y<lines; y++) {
                
                int srcLine     = srcYs - y -1;
                int srcOffset   = srcLine*srcXs  + srcX + xs-1;
                int dstOffset   = (y+dstY)*xs    + dstX ;
                src             = s +srcOffset*4;
                dst             = d +dstOffset;
                
                for (int x=0; x<rows; x++, dst++, src-=4) {	
                    
                    *dst = (src[0]+src[1]+src[2])/3;
                }
            }    
            return true;
        }
    }
 }
bool Buf::copy( byte*s,int srcXs, int srcYs, int srcZs) {
    
	if (!s || !buf) 
		return false;
    
	setup(srcXs,srcYs,srcZs);
    
	byte* src = s+((srcY*srcXs)+srcX) * srcZs;
	byte* dst = buf+((dstY*xs)+dstX)    *    zs;
    
	if (zs<=srcZs) {
		int dz = srcZs-zs;
 		for	 (int y=0; y<copyYs; y++, dst+=dstSkipY,src+=srcSkipY) {
            for (int x=0; x<copyXs; x++,				src+=dz) {	
                for(int z=0; z<zs;	 z++, dst++,		src++) {
                    *dst =  *src;
				}
            }
        }
    }
 	else{
		int dz = zs-srcZs;
        int x,y,z;
 		for	 (y=0; y<copyYs; y++, dst+=dstSkipY,src+=srcSkipY) {
            for (x=0; x<copyXs; x++) {
                for(z=0; z < srcZs; z++, dst++,src++)  
                    *dst = *src;
                for(z=0; z < dz;    z++, dst++)        
                    *dst = 0;
            }
        }
    }
	return true;
}
bool Buf::copyFlipMirror(byte*s,int srcXs, int srcYs, int srcZs) {

	return copyFlip(s,srcXs,srcYs,srcZs);
}
inline void Buf::setup2(int srcXs, int srcYs, int srcZs) {
    
	int xs2 = xs/2;
	int ys2 = ys/2;
    
	if (srcXs < xs2)
    {
		srcSkipY	= 0;						
		dstSkipY	= (xs - srcXs)*zs;	
		srcX	= 0;
		dstX	= (xs2 - srcXs)/2;
		endX	=  dstX  + srcXs;
		copyXs  = srcXs;
    }
	else if (srcXs > xs2)
    {
		srcSkipY = (srcXs-xs2)*srcZs;	
		dstSkipY = xs2*zs;					
		srcX	= (srcXs-xs2)/2;
		dstX	= 0;
		endX	= xs2;
		copyXs  = xs2;
    }
	else{ 
		srcSkipY = 0;					
		dstSkipY = xs2*zs; 					
		srcX	= 0;
		dstX	= 0;
		endX	= srcXs;
		copyXs  = srcXs;
    }
	if (srcYs < ys2)
    {
		srcY	= 0;
		dstY	= (ys2 - srcYs)/2;
		endY	= srcYs + dstY;
		copyYs  = srcYs;
    }
	else if (srcYs > ys2)
    {
		srcY	= (srcYs - ys2)/2;	
		dstY	= 0;	
		endY	= ys2;
		copyYs  = ys2;
    }
	else{
		srcY	= 0;
		dstY	= 0;
		endY	= srcYs;
		copyYs  = ys2;
    }
}
bool Buf::copyFlipMirUp(byte*s,int srcXs, int srcYs, int srcZs) {
    
	if (!s || !buf) 
		return false;
    
	setup2(srcXs,srcYs,srcZs);
	dstSkipY   -= xs*zs*2;
	int dstYup = (dstY+copyYs-1) * xs; 
	byte* src  = s + ((srcY*srcXs)+srcX) * srcZs + srcZs-1;
	byte* dst  = buf + ((dstYup    )+dstX) *    zs;
	int x,y,z;
    
	if (zs<=srcZs) {
        
 		for         (y=0; y<copyYs; y++, dst+=dstSkipY, src+=srcSkipY) 
            for     (x=0; x<copyXs; x++,				src+=(2*srcZs))	
                for (z=0; z<    zs; z++, dst++,         src--) {
                    
                    *dst =  *src;
            }
    }
 	else {
		int dz = zs-srcZs;
        
 		for         (y=0; y<copyYs; y++, dst+=dstSkipY, src+=srcSkipY) 
            for     (x=0; x<copyXs; x++, src+=(2*srcZs))  {
                for (z=0; z<srcZs;	z++, dst++,src--) 	*dst =  *src;
                for (z=0; z<   dz;	z++, dst++)			*dst =  0;
            }
    }
    
	int xs2 = xs/2;
	int ys2 = ys/2;
	int skip = xs*zs;
	int skip2 = xs2*zs;
	src = buf+skip2-zs;
	dst = buf+skip2;
    
	for         (y=0; y<ys2; y++, src=dst+skip2-zs,	dst += skip2)
        for     (x=0; x<xs2; x++, src-=zs*2)
            for (z=0; z<zs ; z++, src++,				dst++) {
            
                *dst = *src;
			}
	
	int start = ys2*xs*zs;
	src = buf + start - skip;
	dst = buf + start;
	
	for         (y=0; y<ys2; y++, src-=skip*2)
        for     (x=0; x<xs ; x++ )
            for (z=0; z<zs ; z++, src++, dst++)
			{
                *dst = *src;
			}
	return true;
}
bool Buf::copyFlipUp(byte*s,int srcXs, int srcYs, int srcZs) {

	if (!s || !buf) 
		return false;
    
	setup(srcXs,srcYs,srcZs);
	dstSkipY -= xs*zs*2;
	int dstYup	  = (dstY+copyYs-1) * xs; 
    
	byte* src  = s + ((srcY*srcXs)+srcX) * srcZs + srcZs-1;
	byte* dst  = buf + ((dstYup    )+dstX) *    zs;
    
	if (zs<=srcZs) {
        
 		for         (int y=0; y<copyYs; y++, dst+=dstSkipY,  src+=srcSkipY) 
            for     (int x=0; x<copyXs; x++,				src+=(2*srcZs))	
                for (int z=0; z<    zs; z++, dst++,         src--)  {
                    
                    *dst =  *src;
				}
    }
 	else {
		int dz = zs-srcZs;
 		for  (int y=0; y<copyYs; y++, dst+=dstSkipY,  src+=srcSkipY) 
         for (int x=0; x<copyXs; x++,				src+=(2*srcZs)) {
                
                int z=0;
                for(; z<srcZs;	z++, dst++,src--) 	*dst =  *src;
                for(    z=0; z<   dz;	z++, dst++)			*dst =  0;
            }
    }
	return true;
}
bool Buf::copyFlip(byte*s,int srcXs, int srcYs, int srcZs) {

	if (!s || !buf) 
		return false;
    
	setup(srcXs,srcYs,srcZs);
    
	byte* src  = s + ((srcY*srcXs)+srcX) * srcZs + srcZs-1;
	byte* dst  = buf + ((dstY*   xs)+dstX) *    zs;
    
	if (zs<=srcZs) {
        
        for         (int y=0; y<copyYs; y++, dst+=dstSkipY,  src+=srcSkipY) 
            for     (int x=0; x<copyXs; x++,				src+=(2*srcZs))	
                for (int z=0; z<    zs; z++, dst++,         src--) {
                    
                    *dst =  *src;
            }
    }
 	else{
		int dz = zs-srcZs;
        int x,y,z;
        
 		for     (y=0; y<copyYs; y++, dst+=dstSkipY, src+=srcSkipY) 
            for (x=0; x<copyXs; x++,				src+=(2*srcZs))	{
            
                for(z=0; z<srcZs;	z++, dst++,src--) 	*dst =  *src;
                for(z=0; z<   dz;	z++, dst++)			*dst =  0;
            }
    }
	return true;
}
bool Buf::copyShift(byte*s,int srcXs, int srcYs, int srcZs,
					int shiftX, int shiftY) {

	if (!s || !buf) 
		return false;
    
	setup(srcXs,srcYs,srcZs);
    
	int xMod = (dstX+shiftX)%xs;
	int yMod = (dstY+shiftY)%ys;
	int xx   = (xMod<0 ? xMod+xs : xMod);
	int yy   = (yMod<0 ? yMod+ys : yMod);
    
	int y0s = MIN(copyYs,ys-yy);	// until end of scanline
	int y1s = copyYs-y0s;			// until end of wrapped scanline
	int x0s = MIN(copyXs,xs-xx);	// until end of scanline
	int x1s = copyXs-x0s;			// until end of wrapped scanline
	int wrap = xs*zs;			// offset to wrap from end to beginning of scanline
    
	int z0s = (zs<=srcZs ?		zs :		  srcZs);
	int z1s = (zs<=srcZs ? srcZs-zs : zs-srcZs);
	
	byte* src = s+ ((srcY*srcXs)+srcX) * srcZs;
	byte* dst;
    int y;
	for	(y=0; y<y0s; y++, src+=srcSkipY) 
    {
		dst = buf + ((yy+y)*xs + xx)*zs;
		copyXz(dst,src,x0s,z0s,z1s,1,1,0);
		dst-=wrap;	// wrap to beginning of scanline
		copyXz(dst,src,x1s,z0s,z1s,1,1,0);
    }
	for	(y=0; y<y1s; y++, src+=srcSkipY) 
    {
		dst = buf + (y*xs + xx)*zs;
		copyXz(dst,src,x0s,z0s,z1s,1,1,0);
		dst-=wrap;	// wrap to beginning of scanline
		copyXz(dst,src,x1s,z0s,z1s,1,1,0);
    }
	return true;
}
bool Buf::copyShiftFlip(byte*s,int srcXs, int srcYs, int srcZs,
						int shiftX, int shiftY) {

	if (!s || !buf) 
		return false;
    
	setup(srcXs,srcYs,srcZs);
    
	int xMod = (dstX+shiftX)%xs;
	int yMod = (dstY+shiftY)%ys;
	int xx   = (xMod<0 ? xMod+xs : xMod);
	int yy   = (yMod<0 ? yMod+ys : yMod);
    
	int y0s = MIN(copyYs,ys-yy);	// until end of scanline
	int y1s = copyYs-y0s;			// until end of wrapped scanline
	int x0s = MIN(copyXs,xs-xx);	// until end of scanline
	int x1s = copyXs-x0s;			// until end of wrapped scanline
	int wrap = xs*zs;			// offset to wrap from end to beginning of scanline
    
	int z0s = (zs<=srcZs ?		 zs :	 srcZs);
	int z1s = (zs<=srcZs ? srcZs-zs : zs-srcZs);
    
	byte* src = s+ ((srcY*srcXs)+srcX) * srcZs + srcZs-1;
	byte* dst;
    int y;
	for	(y=0; y<y0s; y++, src+=srcSkipY) 
    {
		dst = buf + ((yy+y)*xs + xx)*zs;
		copyXz(dst,src,x0s,z0s,z1s,1,-1,2*srcZs);
		dst-=wrap;	// wrap to beginning of scanline
		copyXz(dst,src,x1s,z0s,z1s,1,-1,2*srcZs);
    }
	for	(y=0; y<y1s; y++, src+=srcSkipY) 
    {
		dst = buf + (y*xs + xx)*zs;
		copyXz(dst,src,x0s,z0s,z1s,1,-1,2*srcZs);
		dst-=wrap;	// wrap to beginning of scanline
		copyXz(dst,src,x1s,z0s,z1s,1,-1,2*srcZs);
    }
	return true;
}
bool Buf::copyShift(bool flip,								// byte order
					byte*s,int srcXs, int srcYs, int srcZs,	// source
					int shiftX, int shiftY) {					// shift

	if (flip)
        return copyShiftFlip(s,srcXs,srcYs,srcZs,shiftX,shiftY);
	else 
        return copyShift    (s,srcXs,srcYs,srcZs,shiftX,shiftY);
}
bool Buf::copy( bool flip,								// byte order	
               Buf&srcPix,	// source description
               int srcX,	int srcY,					// source position
               int dstX,	int dstY,					// destination position
               int copyXs, int copyYs) {				// copy rectangle

	return copy(flip,
				srcPix.buf, srcPix.xs,srcPix.ys,srcPix.zs,
				srcX,srcY,
				dstX,dstY,
				copyXs,copyYs);
}
bool Buf::copy( bool flip,								// byte order	
               byte*s,int srcXs,int srcYs,int srcZs,	// source description
               int srcX,	int srcY,					// source position
               int dstX,	int dstY,					// destination position
               int copyXs, int copyYs)	{				// copy rectangle

	if (flip) 
        return copyFlip(s,srcXs,srcYs,srcZs, srcX,srcY,dstX,dstY,copyXs,copyYs);
	else return copy	(s,srcXs,srcYs,srcZs, srcX,srcY,dstX,dstY,copyXs,copyYs);
}

bool Buf::copy( byte*s,int srcXs,int srcYs,int srcZs, // source description
               int srcX,	int srcY, 
               int dstX,	int dstY,
               int copyXs, int copyYs) {

	int srcSkipY = (srcXs - copyXs) * srcZs;
	int dstSkipY = (   xs - copyXs) *    zs;
    
	byte* src = s+((srcY*srcXs)+srcX) * srcZs;
	byte* dst = buf+((dstY*   xs)+dstX) *    zs;
    
	if (zs<=srcZs) {
        
		int dz = srcZs-zs;
 		for	 (int y=0; y<copyYs; y++, dst+=dstSkipY,src+=srcSkipY) 
         for (int x=0; x<copyXs; x++,				src+=dz)	
          for(int z=0; z<zs;	 z++, dst++,		src++)	{
          
                    *dst =  *src;
				}
    }
 	else{
		int dz = zs-srcZs;
        int x,y,z;
 		for	 (y=0; y<copyYs; y++, dst+=dstSkipY,src+=srcSkipY) 
         for (x=0; x<copyXs; x++) {
         
                for(z=0; z<srcZs;z++, dst++,src++) 	*dst =  *src;
                for(z=0;     z<dz;z++,    dst++)			*dst =  0;
            }
    }
	return true;
}
bool Buf::copy8( byte*s,int srcXs,int srcYs,int srcZs, // copy 1/8 size
				int srcX,	int srcXDelta, 
				int dstX,	int dstY,
				int copyXs, int copyYs) {

    int srcY = 0;
    int srcSkipY = ((srcXs-copyXs*8) +(srcXs*7)) * srcZs;
	int dstSkipY = (xs-copyXs)                   *    zs;
    
	byte* src = s+((srcY*srcXs)+srcX*8+srcXDelta) * srcZs;
	byte* dst = buf+((dstY*   xs)+dstX) *    zs;
 	if (zs<=srcZs)
    {
		int dz = (srcZs-zs);
 		for	 (int y=0; y<copyYs; y++, dst+=dstSkipY, src+=srcSkipY) 
            for (int x=0; x<copyXs; x++,				src+=dz)	
                for(int z=0; z<zs;	 z++, dst++,		src++)	
				{
                    *dst =  *src;
				}
    }
 	else{
		//int dz = zs-srcZs;
        unsigned int a[4];
  		for	 (int y=0; y<copyYs; y++, dst+=dstSkipY,src+=srcSkipY) 
            for (int x=0; x<copyXs; x++)
            {
                a[0]=a[1]=a[2]=a[3]=0;
                int xx,z;
                for (xx=0; xx<8; xx++)
                    for(z=0; z < srcZs; z++,src++)
                        a[z] += *src;
                for (int z = 0; z < srcZs; z++,dst++)
                    *dst = a[z]/8; 
                for(          ; z <    zs; z++,dst++)
                    *dst = 0;
		    }
    }
	return true;
}
bool Buf::copyFlip(byte*s,int srcXs,int srcYs,int srcZs, // source description
                   int srcX,	int srcY, 
                   int dstX,	int dstY,
                   int copyXs, int copyYs) {

	int srcSkipY = (srcXs - copyXs) * srcZs;
	int dstSkipY = (   xs - copyXs) *    zs;
    
	byte* src = s+((srcY*srcXs)+srcX) * srcZs + srcZs-1;
	byte* dst = buf+((dstY*   xs)+dstX) *    zs;
    
	if (zs<=srcZs) {

 		for         (int y=0; y<copyYs; y++, dst+=dstSkipY,  src+=srcSkipY) {
            for     (int x=0; x<copyXs; x++,                src+=(2*srcZs))	{
                for (int z=0; z<zs; z++, dst++,             src--) {
                    
                    *dst =  *src;
				}
            }
        }
    }
 	else{
		int dz = zs-srcZs;
        int x,y,z;
 		for         (y=0; y<copyYs; y++, dst+=dstSkipY,  src+=srcSkipY)  {
            for     (x=0; x<copyXs; x++,                src+=(2*srcZs))	{
                
                for (z=0; z<srcZs;	z++, dst++,src--) 	*dst =  *src;
                
                for (z=0; z< dz;    z++, dst++)			*dst =  0;
            }
        }
    }
	return true;
}
Buf::~Buf() {
    
	clear();
}