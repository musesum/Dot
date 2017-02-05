#import <stdlib.h>
#import <ctype.h>
#import <string.h>

#import "../main/CellMain.h" 
#import "../main/SkyDefs.h" 
#import "Colors.h" 
#import "../color/Rgbs.h" 
#import "math.h" 
#import "PalSet.h" 

Colors::Colors(Splice newSplice) {

	_splice = newSplice;
	_colorNow=0;
	_colorSize=9;
	_rgbArray=(Rgb*)malloc(_colorSize*sizeof (Rgb));
	_hsvArray=(Hsv*)malloc(_colorSize*sizeof (Hsv));
	_sizeArray=(int*)malloc(_colorSize*sizeof (int));
}
void Colors::init(Rgb i, Rgb j) {

	_splice = NoSplice;
	addRgb(i);
	addRgb(j);
}
void Colors::init(Hsv i, Hsv j) {

	_splice = NoSplice;
	addHsv(i);
	addHsv(j);
}
bool Colors::resizeColors (int i) {

	if (i >= _colorSize) {
        
		int max2 = max(_colorSize*2,i);
		Rgb* r2=(Rgb*)malloc(max2*sizeof(Rgb)); if (r2==0) return false;
		Hsv* h2=(Hsv*)malloc(max2*sizeof(Hsv)); if (h2==0) return false;
		int* s2=(int*)malloc(max2*sizeof(int)); if (s2==0) return false;
		memcpy(r2,_rgbArray,_colorNow*sizeof(Rgb));
		memcpy(h2,_hsvArray,_colorNow*sizeof(Hsv));
		memcpy(s2,_sizeArray,_colorNow*sizeof(int));
		_colorSize = max2;
		free(_rgbArray); _rgbArray = r2;
		free(_hsvArray); _hsvArray = h2;
		free(_sizeArray); _sizeArray = s2;
    }
	return true;
}
Hsv &Colors::first() {

	if (_colorNow<=0) return palSet.Hsv_Nil;
	return _hsvArray[0];
}
Hsv &Colors::last() {

	if (_colorNow<=0) return palSet.Hsv_Nil;
	return _hsvArray[_colorNow-1];
}
void Colors::setColors(Colors &q) {

	resizeColors (q._colorNow);
	memcpy(_rgbArray, q._rgbArray, q._colorNow*sizeof(Rgb));
	memcpy(_hsvArray, q._hsvArray, q._colorNow*sizeof(Hsv));
	memcpy(_sizeArray, q._sizeArray, q._colorNow*sizeof(int));
	_colorNow =q._colorNow;
	_colorSize =q._colorNow;
	_splice=q._splice;
}
bool Colors::addRgb(Rgb q) {

	resizeColors(_colorNow);
	if (	(_splice & Right) && (_colorNow>0)) {
        
		_rgbArray[_colorNow] = _rgbArray[_colorNow-1];	// move the _splice to the right
		_hsvArray[_colorNow] = _hsvArray[_colorNow-1];
		_rgbArray[_colorNow-1] = q;			// insert _colorNow rgb where spice was
		_hsvArray[_colorNow-1] = rgb2hsv(q);
    }
	else {
		_rgbArray[_colorNow] = q;
		_hsvArray[_colorNow] = rgb2hsv(q);
    }
	_colorNow++;
	return true;
}
bool Colors::addHsv(Hsv q) {
    
	resizeColors(_colorNow);
	if (	(_splice & Right)
        && (_colorNow>0)) {
        
		_hsvArray[_colorNow] = _hsvArray[_colorNow-1]; 	
		_rgbArray[_colorNow] = _rgbArray[_colorNow-1];
		_hsvArray[_colorNow-1] = q;		 	
		_rgbArray[_colorNow-1] = Colors::hsv2rgb(q);
    }
	else {
		_hsvArray[_colorNow] = q;
		_rgbArray[_colorNow] = Colors::hsv2rgb(q);
    }
	_colorNow++;
	return true;
}

/*********************************************************************
 
 abc def
 * 0 0 *:	  <cd>  
 * 1 1 *:	  bbee	
 * 1 0 *:	    dd    
 * 0 1 *:	  cc   
 
 1 * * 1: (eb)       (eb)
 0 * * 0:	a       f
 0 * * 1:    a       a
 1 * * 0:    f       f
 
 abc def
 0 0 0 0:    a <cd> f	
 0 0 0 1:	a <cd> a
 0 0 1 0:	a cc   f
 0 0 1 1:	a cc   a
 
 0 1 0 0:    a   dd f	
 0 1 0 1:	a   dd a
 0 1 1 0:	a bbee f
 0 1 1 1:	a bbee a
 
 1 0 0 0:    f <cd> f	
 1 0 0 1: (eb) <cd> (eb)
 1 0 1 0:	a cc   f
 1 0 1 1: (eb) cc   (eb)
 
 1 1 0 0:    f   dd f	
 1 1 0 1: (eb)   dd (eb)
 1 1 1 0:	f bbee f
 1 1 1 1: (eb) bbee (eb)
 
 
 from left to right:
 
 int ebs2 = (p.s[1] + q.s[q._colorNow-2])/2;
 Hsv eb2  = (p.z[1] + q.z[q._colorNow-2])/2; 
 
 if      (1??1)		{	z[0] = eb2;		s[0] = ebs2;	}
 else if (1???)		{	z[0] = f;		s[0] = p.s[0];	}
 else if (0???)		{	z[0] = a;		s[0] = p.s[0];	}
 
 for (i=1; 
 i<pi; i++) {	z[i] = p.z[i];	s[i] = p.s[i];	}
 
 if      (?11?)							s[i-1]+= q.s[0];}          
 else if (?01?)		{	z[i] = c;		s[i]   = q.s[0];}
 else if (?10?)		{	z[i] = d;		s[i]   = q.s[0];}
 
 else if (?00?)		{	z[i] = c;		s[i]   = 0;		 
 i++;		z[i] = d;		s[i]   = q.s[0];}
 
 
 for (j=1; 
 j<qi; j++,i++) {	z[i] = q.z[j];	s[i] = q.s[j]; }
 
 if      (1??1)		{	z[i] = eb2;	}		
 else if (???0)		{	z[i] = f;	}		
 else if (???1)		{	z[i] = a;	}		
 s[i] = 0;
 
 **********************************************************************/
bool Colors::addColors(Colors &q) {

	resizeColors(_colorNow+q._colorNow);
    
	bool pl  =  _splice & Left;
	bool pr  =  _splice & Right;
	bool ql = q._splice & Left;
	bool qr = q._splice & Right;
    
	int qn = q._colorNow;
    
	Hsv &a =   _hsvArray[0];	Hsv &c = _hsvArray[_colorNow-1];
	Hsv &d = q._hsvArray[0];	Hsv &f = q._hsvArray[qn -1];
	Hsv eb2  = middle(_hsvArray[1],  q._hsvArray[qn-2]); 
	
	if      ( pl && qr) {	_hsvArray[0] = eb2;		}
	else if ( pl)		{	_hsvArray[0] = f;		}
	else if (!pl)		{	_hsvArray[0] = a;		}
    
	int i = _colorNow-1;
    
	if      ( pr &&  ql)	{                               _sizeArray[i-1]+= q._sizeArray[0];}          
	else if (!pr &&  ql)	{ _hsvArray[i] = c;             _sizeArray[i] = q._sizeArray[0];}
	else if ( pr && !ql)	{ _hsvArray[i] = d;             _sizeArray[i] = q._sizeArray[0];}
	
	else if (!pr && !ql)	{ _hsvArray[i] = c;             _sizeArray[i] = 0;		
                      i++;    _hsvArray[i] = d;             _sizeArray[i] = q._sizeArray[0];}
    int j=1;
	for (; j<qn; j++, i++)  { _hsvArray[i] = q._hsvArray[j]; _sizeArray[i] = q._sizeArray[j];}
    
	if      (pl && qr)      { _hsvArray[i] = eb2;}		
	else if (	 !qr)       { _hsvArray[i] = f;	 }		
	else if (	  qr)       { _hsvArray[i] = a;	 }	
    
	/* finally */                                               _sizeArray[i] = 0;
    
	_colorNow = i+1;
	for ( i=0; i<_colorNow; i++)
		_rgbArray[i]=Colors::hsv2rgb(_hsvArray[i]);
    
	return true;
}

bool Colors::ramps(Rgbs &q, int size) {

	if (_colorNow<2)                // not enough colors to create ramp?
        return false;
	bool flip = (size<0 ? 1 : 0);
	size=abs(size);
	int rampCount=0;                // total rendered ramps
	Rgbs p;
	if (size==1) {
        
		p.ramp(_rgbArray[0],_rgbArray[0],1);
		q.addRgbs(p);
    }
	else if (flip) {
        
		for (int i=_colorNow-1, nowi = _colorNow-1; 
             i>0,	  nowi>0;
             i--,	  nowi--) {                 // subsequent ramps
        
			int vnow = (size-rampCount)/nowi;	// new ramps to render
			rampCount += vnow;                  // update total ramps rendered
			p.ramp(_rgbArray[i],_rgbArray[i-1],vnow);
			q.addRgbs(p);
        }
    }
	else {
        
 		for (int i=0,	nowi=_colorNow-1;
			 i < (_colorNow-1), nowi>0; 
			 i++,		nowi--)	{               // subsequent ramps
        
			int vnow = (size-rampCount)/nowi;   // new ramps to render
			rampCount += vnow;                  // update total ramps rendered
			p.ramp(_rgbArray[i],_rgbArray[i+1],vnow);
			q.addRgbs(p);
        }
    }
	return true;
}
int inline Colors::between (int i, int j, int x, int y)  {
    
#if DebugRanges
    if  (i<0 || i>360 ||
         j<0 || j>360 ||
         x<0 || x>255 ||
         y<0 || y>255 ||
         j <= i ||
         x <= j
         )
        err.fail ("between: out of range")
#endif
        
        if ((x+y)==0) return i;
    
	int ji2  = (j-i)/2;
	int ret = i+ ji2 + ji2 * (x-y)/(x+y);
    
	return ret;
}

inline Hsv & Colors::middle(Hsv &p,	Hsv &q) {

	static Hsv ret;
	ret.h = (p.h + q.h) / 2;
	ret.s = (p.s + q.s) / 2;
	ret.v = (p.v + q.v) / 2;
	return ret;
}


// r,g,b values are from 0 to 1
// h = [0,360], s = [0,1], v = [0,1]
//		if s == 0, then h = -1 (undefined)
void RGBtoHSV( float r, float g, float b, float* h, float* s, float* v )
{
	float min, max, delta;
	min = MIN( r, MIN(g, b ));
	max = MAX( r, MAX(g, b ));
	*v = max;				// v
	delta = max - min;
	if( max != 0 )
		*s = delta / max;		// s
	else {
		// r = g = b = 0		// s = 0, v is undefined
		*s = 0;
		*h = -1;
		return;
	}
	if( r == max )
		*h = ( g - b ) / delta;		// between yellow & magenta
	else if( g == max )
		*h = 2 + ( b - r ) / delta;	// between cyan & yellow
	else
		*h = 4 + ( r - g ) / delta;	// between magenta & cyan
	*h *= 60;				// degrees
	if( *h < 0 )
		*h += 360;
}
void HSVtoRGB(float h, float s, float v, float* r, float* g, float* b )
{
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0: *r = v; *g = t; *b = p; break;
		case 1: *r = q; *g = v; *b = p; break;
		case 2: *r = p; *g = v; *b = t; break;
		case 3: *r = p; *g = q; *b = v; break;
		case 4: *r = t; *g = p; *b = v; break;
		case 5: *r = v; *g = p; *b = q; break;
	}
}

Hsv &Colors::rgb2hsv (Rgb &rgb) {
    
    static Hsv hsv; 
#if 1
    float h,s,v;
    float r = (float)rgb.r;
    float g = (float)rgb.g;
    float b = (float)rgb.b;
    RGBtoHSV(r/255.,g/255.,b/255.,&h,&s,&v);
    hsv.h = (unt)(h);
    hsv.s = (unt)(s*100);
    hsv.v = (unt)(v*100);
    return hsv;
#else
	unt r = rgb.r;
	unt b = rgb.b;
	unt g = rgb.g;
    
	unt hue;	
	unt sat;	
	unt bri;	
	RgbSort sort;
    
	if		(r>=g) {
        
		if	(g>=b)	sort = Irgb;
		else		sort = Irbg;
    }
	else if	(g>=b) {
        
		if	(b>=r)	sort = Igbr;
		else		sort = Igrb;
    }
	else {
        
		if	(g>=r)	sort = Ibgr;
		else		sort = Ibrg;
    }
	switch (sort) {	// 15 bit fractional part
            
		case Irgb: 
		case Igrb: hue = between (  0,120,r,g); break;
		case Igbr: 
		case Ibgr: hue = between (120,240,g,b); break;
		case Ibrg: 
		case Irbg: hue = between (240,360,b,r); break;
    }
	switch (sort) {
            
		case Irgb: sat = ((r-b) *100) / r; break;
		case Igrb: sat = ((g-b) *100) / g; break;
		case Igbr: sat = ((g-r) *100) / g; break;
		case Ibgr: sat = ((b-r) *100) / b; break;
		case Ibrg: sat = ((b-g) *100) / b; break;
		case Irbg: sat = ((r-g) *100) / r; break;
    }
	switch (sort) {
            
		case Irgb: 
		case Irbg: bri = (r * 100) / 255; break;
            
		case Igbr: 
		case Igrb: bri = (g * 100) / 255; break;
            
		case Ibgr: 
		case Ibrg: bri = (b * 100) / 255; break;
    }
    hsv.h = hue;
    hsv.s = sat;
    hsv.v = bri;
    return hsv;
#endif

}
#pragma optimize( "", off )
Rgb &Colors::Colors::hsv2rgb (Hsv hsv) {
    
        static Rgb crgb;
#if 1
    float r,g,b;
    float h = (float)hsv.h;
    float s = (float)hsv.s;
    float v = (float)hsv.v;
    
    HSVtoRGB(h,s/100,v/100,&r,&g,&b);
    
    crgb.r = (unt)(r*255);
    crgb.g = (unt)(g*255);
    crgb.b = (unt)(b*255);
    
#else
    
	unt r,g,b;
	unt h = hsv.h;
	unt s = hsv.s;
	unt v = hsv.v;
	unt vv = (255*v)/100;	
    
#define up(w,x,y,z) (w + (x-w)*(h-y)/(z-y)) /* up the ramp */
#define dn(w,x,y,z) (x - (x-w)*(h-y)/(z-y)) /* down the ramp */
    
	if      (h< 60) { r=vv; b = r - r*s/100; g = up(b,r,  0, 60); }
	else if (h<120) { g=vv; b = g - g*s/100; r = dn(b,g, 60,120); }
	else if (h<180) { g=vv; r = g - g*s/100; b = up(r,g,120,180); }
	else if (h<240) { b=vv; r = b - b*s/100; g = dn(r,b,180,240); }
	else if (h<300) { b=vv; g = b - b*s/100; r = up(g,b,240,300); }
	else if (h<360) { r=vv; g = r - r*s/100; b = dn(g,r,300,360); }
    
	crgb.r = r;
	crgb.g = g;
	crgb.b = b;
    //fprintf(stderr, "rgb(%i,%i,%i)\n",r,g,b);
#endif
	return crgb;
}
#pragma optimize( "", on )

