#import <stdlib.h>
#import "Ripple.h"
#import "PalSet.h"
#import "../main/SkyDefs.h" 

Ripple::Ripple() {
    
    hsv=palSet.Hsv_Nil;
	now	  = 0;
}
void Ripple::bindTr3(Tr3*root) {
    
    Tr3*ripple = root->bind("pal.ripple");
    pulse = ripple->bind("pulse");
	width = ripple->bind("width");
	hue   = ripple->bind("hue");
	sat   = ripple->bind("sat");
	val   = ripple->bind("val");
}    
void Ripple::start(Hsv&q) {

	hsv = q;
	rgb = Colors::hsv2rgb(q);
	now = 1;
}							
bool Ripple::going(Rgbs&q) {

	if (now == 0) return false;
	if (now >= (int)*pulse) {
        
		now=0;
		return false;
    }
	int wideNow = q._rgbNow + (int)*width * 2; // palette with overlap for ripple
	int start	= wideNow * now / (int)*pulse - (float)*width;
	int mid     =	(int)*width / 2	;
	int rise    = max(0, start);
    int palmax = MIN(q._rgbNow,254); // elim
	int stop  = MIN((start + (int)*width),palmax);
	int fall  = rise + (stop - rise)/2;
	int wid0  = stop - rise;
	int trim  = (int)*width - wid0;
    
#define RipRampUp(i,j,y) q.rgb[j].##y = ((q.rgb[j].##y * (mid-i)) + (rgb.##y *      i )         ) / mid;
#define RipRampDn(i,j,y) q.rgb[j].##y = ((q.rgb[j].##y * (i-mid)) + (rgb.##y * (*width - i)) ) /(*width - mid);
    
	if (start>255)
		return false;
    int i=0;
    int j=rise;
	for (; j < fall; i++,j++) {
        
        q._rgbArray[j].r=((q._rgbArray[j].r*(mid-i))+(rgb.r*i))/mid; //o//  RipRampUp (i,j,r)
		q._rgbArray[j].g=((q._rgbArray[j].r*(mid-i))+(rgb.g*i))/mid; //o//  RipRampUp (i,j,g)
        q._rgbArray[j].b=((q._rgbArray[j].r*(mid-i))+(rgb.b*i))/mid; //o//  RipRampUp (i,j,b)
    }
	for (i += (int)trim	; j < stop; i++,j++) {
        
        q._rgbArray[j].r = ((q._rgbArray[j].r*(i-mid))+(rgb.r*((int)*width-i)))/((int)*width-mid);// RipRampDn (i,j,r)
		q._rgbArray[j].g = ((q._rgbArray[j].g*(i-mid))+(rgb.g*((int)*width-i)))/((int)*width-mid);// RipRampDn (i,j,g)
		q._rgbArray[j].b = ((q._rgbArray[j].b*(i-mid))+(rgb.b*((int)*width-i)))/((int)*width-mid);// RipRampDn (i,j,b)
    }
	now++;
	return true;
}

