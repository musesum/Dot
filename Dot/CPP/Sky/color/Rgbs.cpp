#import <stdlib.h>
#import <string.h>
#import "Rgbs.h"
#import "../main/SkyDefs.h" 

Rgbs::Rgbs() {

	_rgbNow = 0;
	_rgbMax = 0;
	_rgbArray = 0;
}
void Rgbs::clear() {
    
	_rgbNow =0;
}
bool Rgbs::ramp(Rgb &from, Rgb&to, int newSize) {

    if (!resizeRgb (newSize) || !_rgbArray || _rgbNow <1)
        return false;	 
    else ; // _rgbNow = newSize in size(newSize);
    
    Rgb* pi = _rgbArray;
    if (_rgbNow==1) {
        pi->r = to.r; // operator * / precedence limits rounding error
        pi->g = to.g;
        pi->b = to.b;
    }
    else {
        int rd = to.r - from.r; // deltas--used for readability
        int gd = to.g - from.g;
        int bd = to.b - from.b;
        
        for (int i=0; i<_rgbNow; i++, pi++) {
            
            pi->r = from.r + (rd* i /(_rgbNow-1)); // operator * / precedence limits rounding error
            pi->g = from.g + (gd* i /(_rgbNow-1));
            pi->b = from.b + (bd* i /(_rgbNow-1));
        }
    }
    return true;
}
bool Rgbs::ramp(Hsv &from, Hsv &to, int newSize) {

    if (!resizeRgb (newSize))
        return false;	 
    else ; // _rgbNow = newSize in size(newSize);
    
    int hd = to.h -from.h; // deltas--used for readability
    int sd = to.s -from.s;
    int vd = to.v -from.v;
    if (hd > 180) hd -= 360;
    if (hd <-180) hd += 360;
    
    Rgb* pi = _rgbArray;
    Hsv hsv;
    for (int i=0; i<_rgbNow; i++, pi++) {
        
        int h = from.h + (hd* i /(_rgbNow-1)); // operator * / precedence limits rounding error
        int s = from.s + (sd* i /(_rgbNow-1));
        int v = from.v + (vd* i /(_rgbNow-1));
        while (h<0) h += 360; //TODO: wtf?
        if (h>360) h %= 360;
        if (s<0) s = 0;
        if (v<0) v = 0;
        hsv.h =h;
        hsv.s =s;
        hsv.v =v;
        *pi = Colors::hsv2rgb(hsv);
    }
    return true;
}
bool Rgbs::fade(Rgbs&r, Rgbs &q, int ratio) {

    int newSize = MAX(q._rgbNow,r._rgbNow);
    if (!resizeRgb (newSize))
       
        return false;	 
    else 
        ; // _rgbNow = newSize in size(newSize);
    
    int size = MIN(q._rgbNow, r._rgbNow);
    Rgb* pi =   _rgbArray;
    Rgb* qi = q._rgbArray;
    Rgb* ri = r._rgbArray;
    int i;

#define Interpol(qq,rr) (byte) ((((int)qq)* ratio + ((int)rr)*(255-ratio))/255);
    
    if (ratio<=0) {			// ignore q
        
        for (i=0; i<r._rgbNow; i++, pi++, qi++, ri++) {
            pi->r = ri->r;
            pi->g = ri->g;
            pi->b = ri->b;
        }
    }
    else if (ratio>=255) {	// ignore p
     
        for (i=0; i<q._rgbNow; i++, pi++, qi++, ri++) {
            
            pi->r = qi->r;
            pi->g = qi->g;
            pi->b = qi->b;
        }
    }
    else {				   // mix p & q
        
        for (i=0; i<size; i++, pi++, qi++, ri++)  {
            
            pi->r = Interpol(qi->r,ri->r);
            pi->g = Interpol(qi->g,ri->g);
            pi->b = Interpol(qi->b,ri->b);
        }
    }
    Rgb* si = (q._rgbNow > r._rgbNow ? qi : ri);
    for ( ; i<_rgbNow; i++,si++) { // in case p & q are differnt sizes   
        
        pi->r = si->r;
        pi->g = si->g;
        pi->b = si->b;
    }
    return true;
}
bool Rgbs::bw(float ratio) {

	int floor	= 0x00;
	int ceiling = 0xFF;
    
	if (ratio >= 0.6) {
        
		float factor = (ratio-0.6) * 0.5/0.4;
		floor = (int) (512.0* factor);
    }
	else if(ratio <= 0.4) {
        
		float factor = ratio * 0.5/0.4;
		ceiling = (int)(512.0 * factor);
    }
	else{
		return false;
    }
	int delta = ceiling-floor;
	
	Rgb* pi = _rgbArray;
	if (ceiling==0) {
        
		for (int i=0; i<_rgbNow; i++, pi++) {
            
			pi->r = 0;
			pi->g = 0;
			pi->b = 0;
        }
    }
	else if(floor==0xFF) {
        
		for (int i=0; i<_rgbNow; i++, pi++) {
            
			pi->r = 0xFF;
			pi->g = 0xFF;
			pi->b = 0xFF;
        }
    }
	else{
        
		for (int i=0; i<_rgbNow; i++, pi++) {
            
			pi->r = ((pi->r)*delta)/0xFF +floor;
			pi->g = ((pi->g)*delta)/0xFF +floor;
			pi->b = ((pi->b)*delta)/0xFF +floor;
        }
    }
	return true;		
}
bool Rgbs::flip() {

    int last = MIN(_rgbNow,256) - 1;
    Rgb* pi =   _rgbArray;
    Rgb* qi = pi+last;
#define Swap(x,y) z=x; x=y; y=z;

    for (int i=0,z; i<last/2; i++, pi++, qi--) {
        
        Swap (pi->r , qi->r);
        Swap (pi->g , qi->g);
        Swap (pi->b , qi->b);
    }
    return true;
}
bool Rgbs::resizeRgb (int size) {

	if (size==0) 
        return false;
    
	if (!_rgbArray || size > _rgbMax) {
        
		if (_rgbArray) free (_rgbArray);
		_rgbMax = size;
		_rgbArray = (Rgb*)malloc(_rgbMax * sizeof(Rgb));
		if (_rgbArray==0) return false;
    }
	_rgbNow = size;
	return true;
}
void Rgbs::addRgbs(Rgbs &rgbs_) {

	if (_rgbNow + rgbs_._rgbNow>_rgbMax) {
        
		_rgbMax = _rgbNow + rgbs_._rgbNow;
		void*q = malloc(_rgbMax * sizeof(Rgb));
		if (_rgbArray) {
            
			memcpy (q, _rgbArray, _rgbNow * sizeof(Rgb));
			free (_rgbArray);
			_rgbArray=0;
        }
		_rgbArray = (Rgb*) q;
    }
	memcpy (_rgbArray+_rgbNow,rgbs_._rgbArray,rgbs_._rgbNow*sizeof(Rgb));
	_rgbNow += rgbs_._rgbNow;
}
void Rgbs::setRgbs(Rgbs&rgbs_) {

	resizeRgb(rgbs_._rgbNow);			// resizes _rgbArray, changes: _rgbArray, _rgbNow, _rgbMax
	if (rgbs_._rgbNow>0)
		memcpy (_rgbArray, rgbs_._rgbArray, rgbs_._rgbNow*sizeof(Rgb));
    
}

