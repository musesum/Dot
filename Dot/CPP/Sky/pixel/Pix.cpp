#import "Pix.h"
#import "../main/SkyWinDef.h"
#import "../main/SkyDefs.h"
#import "../main/CellMain.h"
#import <stdlib.h>
#import <stdio.h>

Pix::Pix() {
    
    for (int i=0; i<FaceMax; i++) {
		buf[i]	= 0; 
    }
	bufSize		= 0;
	bufCount	= 1;
	palz		= 0;	
	rgbPlanes	= 0;
	palPlanes	= 0;
    initialized = false;
}
void Pix::bindTr3(Tr3*root) {

    Tr3*screen  = root->bind("screen");
    
	realfake  = screen->bind("realfake");
    
	fadeFake  = screen->bind("fade.fake");
	fadeReal  = screen->bind("fade.real");
	fadeCross = screen->bind("fade.cross");
	
	lumaSize  = screen->bind("luma.size");
	lumaBlack = screen->bind("luma.black");
	lumaWhite = screen->bind("luma.white");
    
}
void Pix::init(Tr3*root, int zs) {
    
    if (!initialized) {
        
        initialized = true;
        bindTr3(root);
        planes = zs*8;
        pals.init(root);
    }
}

void Pix::goPix(FaceMap&facemap, Buf&pix8, Buf&pix32) {
    
	pals.goPal();
	rePlane(facemap,pix8,pix32); // sets buf 
}
void Pix::bwPal() {
	
    if (!pals.rgbz._rgbArray) {		// no palette yet?
    
		pals.rgbz.resizeRgb(256); // make a grey one
		Rgb*pi=pals.rgbz._rgbArray;
        
		for (int i=0; i<256; i++,pi++) {
			pi->r=i;
			pi->g=i;
			pi->b=i;
			pi->a=0;
        }
    }
}
bool Pix::setPal() {
    
	if (palz) {
        
		if (rgbPlanes != planes) {
            
			free (palz);
			palPlanes=0;
			palz=0;
        }
    }
	if (!palz) {
        
		switch (planes) {
                
			case 16: palz = malloc(256*sizeof(Rgb16)); break;
			case 24: palz = malloc(256*sizeof(Rgb24)); break;
			case 32: palz = malloc(256*sizeof(Rgb32)); break;
			default: return false;
        }
		if (palz)
			palPlanes = planes;
    }
	bwPal();
	Rgb*pi = pals.final._rgbArray;
    
	switch (planes) {
            
		case 16: {
            
            Rgb16* pz = (Rgb16*) palz;
            for (int i=0; i<256; i++,pz++,pi++) {
                
                int r = pi->r;
                int g = pi->g;
                int b = pi->b;
                pz->rgb = ((r&0xf8)<<7)	// 5 bits
                | ((g&0xf8)<<2)	// 5 bits
                | ((b&0xf8)>>3);	// 5 bits
            }
            break;
        }
		case 24: {
            
            Rgb24* pz = (Rgb24*)palz;
            for (int i=0; i<256; i++,pz++,pi++) {

                pz->r = pi->r; // MIN(255,pi->r); //TODO: remove these comments after test
                pz->g = pi->g; // MIN(255,pi->g);
                pz->b = pi->b; // MIN(255,pi->b);
            }
            break;
        }
		case 32: {
            
            Rgb32* pz = (Rgb32*)palz;
            for (int i=0; i<256; i++,pz++,pi++) {
                
                pz->a = 0;
                pz->r = pi->r; // MIN(255,pi->r);
                pz->g = pi->g; // MIN(255,pi->g);
                pz->b = pi->b; // MIN(255,pi->b);
            }
            break;
        }
    }
	return true;
}
bool Pix::setBuf(FaceMap &facemap,Buf&pix8,Buf&pix32) {
	
    int newBufCount = 1; //o// bypass script, for now
    /*
     int newBufCount = facemap.tileSurfs;
     if (	((*facemap.foreground==0) || (*facemap.rendertex==1))
     && facemap.faceMapType!=Cube6Unique)
     newBufCount = 1; 
     */
	int tile8BufSize = pix8.xs * pix8.ys;
	int tile32BufSize = pix32.xs * pix32.ys;
	int tileBufSize = tile8BufSize;
    
	if (tile8BufSize != tile32BufSize)
		tileBufSize = MIN(tile8BufSize, tile32BufSize);
    int i;
	for (int i=0; i<FaceMax; i++) {
        
		if (buf[i])	{
            
			if (	rgbPlanes != planes			// change in main.screen resolution
				||	bufSize   != tileBufSize	// change in main.screen dimensions
				||	         i > newBufCount) {	// fewer buffers needed now
                
				free (buf[i]);
				buf[i] = 0;
            }
        }
    }
	rgbPlanes = planes;
	bufCount  = newBufCount;
	bufSize   = tileBufSize;
    
    for (i=0; i<bufCount; i++) {
        
		if (!buf[i]) {
			if (bufSize > 0) {
                switch (planes) {
                    case 16: buf[i] = (Rgb16*)malloc(bufSize*sizeof(Rgb16)); break;
                    case 24: buf[i] = (Rgb24*)malloc(bufSize*sizeof(Rgb24)); break;
                    case 32: buf[i] = (Rgb32*)malloc(bufSize*sizeof(Rgb32)); break;
                    default: return false;
                }
            }
			if (!buf[i])
				return false;
        }
    }
	return true;
}
bool Pix::setBmp(void* buf, byte* pseudo) {
    
	if (!pseudo || !palz)	
		return false;
    
	switch (planes) {
		case 16: {
            Rgb16* pz = (Rgb16*)palz;
            Rgb16* rz = (Rgb16*)buf;
            byte*  fake = pseudo;
            for (int j=0; j<bufSize; j++, rz++,fake++)
                *rz = pz[*fake];
            break;
        }
		case 24: {
            Rgb24* pz = (Rgb24*)palz;
            Rgb24* rz = (Rgb24*)buf;
            byte*  fake = pseudo;
            for (int j=0; j<bufSize; j++, rz++,fake++)
                *rz = pz[*fake];
            break;
        }
		case 32: {
            Rgb32* pz = (Rgb32*)palz;
            Rgb32* rz = (Rgb32*)buf;
            byte*  fake = pseudo;
            for (int j=0; j<bufSize; j++, rz++,fake++)
                *rz = pz[*fake];
            break;
        }
    }
	return true;
}
int ratio(int lo, int hi, Tr3*tr3) {

    if (!tr3 || ! tr3->val)
        return 0;
    Tr3ValScalar* v = (Tr3ValScalar*)tr3->val;
	int min = (int)(v->min);
	int max = (int)(v->max);
	int val = (int)(v->num);
	int srcRange = max-min;
	int dstRange = (hi-lo);
	int result = (val-min) * dstRange / srcRange + lo;
	return result;
}

//TODO: make this easier to understand; use inline, longer names

#define SmallArray 1
#ifdef SmallArray	
#define mxi 256	
#define mxm	  1
#define mxd	  3
#else
#define mxi 768
#define mxm	  3
#define mxd	  1
#endif

#define reali 1
#define fakei 0

byte f	 [2][mxi][256];	// fade
byte fade[2][mxi];
int fades[2];

void Pix::setFade(bool &realist) {
    
	static int oldM = -1;	// merge
	static int oldW = -1;	// white
	static int oldB = -1;	// black
	static int oldFr = -1;	// fake fader index
	static int oldFf = -1;	// real fader index
    
#define between(x,y,z) max(x,MIN(y,z))
	
	int m	= ratio( 1,mxi/2,lumaSize);					// merge white and black
	int w	= ratio(-m,mxi	,lumaWhite);			
	int b	= ratio( 0,mxi+m,lumaBlack); 
    
	fades[reali] = ratio(0,mxi,fadeReal);
	fades[fakei] = ratio(0,mxi,fadeFake);
    
	realist = (b-w < m ? true : false);
	
	if (	m  == oldM 
		&&	w  == oldW 
		&&	b  == oldB
		&&	fades[reali] == oldFr
		&&	fades[fakei] == oldFf)
		return ;
	oldM  = m;
	oldW  = w;
	oldB  = b;
	oldFr = fades[reali];
	oldFf = fades[fakei];
    
	int w0 = w;		int w1 = w0+m; // white begin end
	int b1 = b;		int b0 = b1-m;	// black end begin
	
	int w00 = between(0,w0,mxi);
	int w11 = between(0,w1,mxi);
	int b00 = between(0,b0,mxi);
	int b11 = between(0,b1,mxi);
	int i,j,jj;
    
	for (int k=0;k<mxi;k++) {
		fade[reali][k] = k*fades[reali]/mxi/mxm;
		fade[fakei][k] = k*fades[fakei]/mxi/mxm;
    }
	int ee;
    
#define ForIJ(hh,ii,e)\
    for(;i<ii;i++){\
        for(j=0;j<256;j++){\
            jj=j*mxm; \
            ee=e; \
            f[hh][i][j]   = fade[hh][ee]; \
            f[hh^1][i][j] = fade[hh^1][jj-ee]; }}

    int distance = b-w;
	
	i=0;
	
	if (distance <	0*m/2) {
    
		ForIJ(0,b00,	jj)
		ForIJ(0,b11,	jj*(b1-i)/m)
		ForIJ(0,w00,	0)
		ForIJ(0,w11,	jj*(i-w0)/m)
		ForIJ(0,mxi,	jj)
    }
	else if (distance <= 1*m/2) {
    
		ForIJ(0,b00,jj)
		ForIJ(0,w00,jj*(b1-i )/m)
		ForIJ(0,b11,jj*(b1-w0)/m)
		ForIJ(0,w11,jj*( i-w0)/m)
		ForIJ(0,mxi,jj)
    }
	else if (distance <= 2*m/2) { // distance(m/2:m)*/m::(0.5 : 1.0)    

		float rr = 1.0-((float)distance/(float)m); // (0.5 : 0.0)
		int r0 = (int) (rr*1024.0);
        
		ForIJ(0,b00,jj/2 + (jj*r0 				/1024)) 
		ForIJ(0,w00,jj/2 + (jj*r0*(w0-i)/(w0-b0)/1024)) 
		ForIJ(0,b11,jj/2)
		ForIJ(0,w11,jj/2 + (jj*r0*(i-b1)/(w1-b1)/1024)) 
		ForIJ(0,mxi,jj/2 + (jj*r0				/1024)) 
    }
	else if (distance <= 3*m/2) {
        
		float ff = ((float)distance/(float)m)-1.0;
		int f0 = (int)(ff*1024.0);
        
		ForIJ(1,w00,jj/2 + (jj*f0 				/1024))
		ForIJ(1,b00,jj/2 + (jj*f0*(b0-i)/(b0-w0)/1024)) 
		ForIJ(1,w11,jj/2)
		ForIJ(1,b11,jj/2 + (jj*f0*(b1-i)/(b1-w1)/1024)) 
		ForIJ(1,mxi,jj/2 + (jj*f0				/1024)) 
    }
	else if (distance <= 4*m/2) {
        
		ForIJ(1,w00,jj)
		ForIJ(1,b00,jj*(w1-i )/m)
		ForIJ(1,w11,jj*(w1-b0)/m)
		ForIJ(1,b11,jj*( i-b0)/m)
		ForIJ(1,mxi,jj)
    }
	else {
		ForIJ(1,w00,jj)
		ForIJ(1,w11,jj*(w1-i)/m)
		ForIJ(1,b00,0)
		ForIJ(1,b11,jj*(i-b0)/m)
		ForIJ(1,mxi,jj)
    }
}
bool Pix::setBmp(void* buf, int* full, byte* pseudo) {
    
	if (!full || !pseudo || !palz)	
		return false;
	bool realist;
	setFade(realist);
    
	int mono;
    
	switch (planes) {
            
		case 24: {
            
            Rgb24* pz = (Rgb24*)palz;
            Rgb24* rz = (Rgb24*)buf;
            Rgb32* real = (Rgb32*)full;
            byte*  fake = pseudo;
            for (int j=0; j<bufSize; j++, rz++,fake++,real++) {
                
                if (realist) mono = (    real->b +     real->g +     real->r)/mxd;
                else	     mono = (pz[*fake].b + pz[*fake].g + pz[*fake].r)/mxd;
                
                rz->b = f[reali][mono][real->b] + f[fakei][mono][pz[*fake].b];  
                rz->g = f[reali][mono][real->g] + f[fakei][mono][pz[*fake].g];
                rz->r = f[reali][mono][real->r] + f[fakei][mono][pz[*fake].r];
            }
            break;
        }
		case 32: {
            
            Rgb32* pz = (Rgb32*)palz;
            Rgb32* rz = (Rgb32*)buf;
            Rgb32* real = (Rgb32*)full;
            byte*  fake = pseudo;
            
            for (int j=0; j<bufSize; j++, rz++,fake++,real++) {
                
                if (realist) mono = (    real->b +     real->g +     real->r)/mxd;
                else		 mono = (pz[*fake].b + pz[*fake].g + pz[*fake].r)/mxd;
                
                rz->a = 0;
                rz->b = f[reali][mono][real->b] + f[fakei][mono][pz[*fake].b];  // from 0..(lumaBlack)/3  :: pz[]..0
                rz->g = f[reali][mono][real->g] + f[fakei][mono][pz[*fake].g];
                rz->r = f[reali][mono][real->r] + f[fakei][mono][pz[*fake].r];
            }
            break;
        }
    }
	return true;
}
bool Pix::setBmp(void* buf, int* full) {
    
	if (!full )	
		return false;
    
	for (int i=0; i<bufCount; i++) {
		
		switch (planes) {
                
			case 24: {
                
                Rgb24* rz = (Rgb24*)buf;
                Rgb32* real = (Rgb32*)full;
                
                for (int j=0; j<bufSize; j++, rz++, real++) {
                    rz->b = real->b ;
                    rz->g = real->g ;
                    rz->r = real->r ;
                }
                break;
            }
			case 32: {
                
                Rgb32* rz = (Rgb32*)buf;
                Rgb32* real = (Rgb32*)full;
                
                for (int j=0; j<bufSize; j++, rz++,real++) {
                    
                    rz->a = 0;
                    rz->b = real->b ;
                    rz->g = real->g ;
                    rz->r = real->r ;
                }
                break;
            } 
        }
    }
	return true;
}
void **Pix::rePlane(FaceMap &facemap, Buf&pix8, Buf&pix32) {
    
	if (planes==8 || !setPal()) {
        
		return (void**)pix8.buf; /// pic.pix8.buf;
    }
	bool ret = setBuf(facemap,pix8,pix32);
	if (!ret) {
        
		planes = 8;        
		return (void**)pix8.buf; /// pic.pix8.buf;
    }
	for (int i=0; ret && i<bufCount; i++) {
        
		if (((int)*realfake==100 || pix32.buf == 0) && pix8.buf) {
            
            ret &= setBmp(buf[i],pix8.buf);
        }
		else if ((int)*realfake==0 && pix32.buf) {
            
            ret &= setBmp(buf[i],(int*)pix32.buf);
        }
		else if (pix32.buf && pix8.buf) { // realfake >0 <100 	
            
            ret &= setBmp(buf[i],(int*)pix32.buf,pix8.buf);
        }
		else {
            
            ret = false;
        }
    }
    return (void**)buf;
}
