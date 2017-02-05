#import "Shift.h"
#import "../main/SkyWinDef.h"
#import "../time/SkyClock.h"

Shift::Shift() {

	deltaX = 0;
	deltaY = 0;
}

void Shift::bindTr3(Tr3*root, const char *label) {
    
    Tr3*shift = root->bind("screen.shift");
    shift   = shift->bind(label);
    
	on      = shift->bind("on");
	reverse	= shift->bind("reverse");
	
    sum = shift->bind("sum");
    sumX = (*sum)[0];
    sumY = (*sum)[1];
    
    ofs = shift->bind("ofs");
    ofsX = (*ofs)[0];
    ofsY = (*ofs)[1];
    
    add = shift->bind("add");
    addX = (*add)[0];
    addY = (*add)[1];
   
    sumPrevX = 0; sumPrevY = 0;
    ofsPrevX = 0; ofsPrevY = 0;
    sumNowX  = 0; sumNowY  = 0;
    ofsNowX  = 0; ofsNowY  = 0;
    addNowX  = 0; addNowY  = 0;
    
 }

/* called by Pic.cpp to get univ shift
 */
void Shift::getDelta(int&dx, int &dy) {

	dx = deltaX;
	dy = deltaY;
    
}
void Shift::go() {
    
    if (*on) {
        
        sumNowX = *sumX; sumNowY = *sumY;
        ofsNowX = *ofsX; ofsNowY = *ofsY;
        addNowX = *addX; addNowY = *addY;
        revNow = *reverse;
        
        *sumX = sumNowX + (ofsNowX-ofsPrevX) + addNowX * (revNow ? -1 : 1);
        *sumY = sumNowY + (ofsNowY-ofsPrevY) + addNowY * (revNow ? -1 : 1);
        
        deltaX = sumNowX - *sumX;
        deltaY = sumNowY - *sumY;
        
        sumPrevX = sumNowX; sumPrevY = sumNowY;
        ofsPrevX = ofsNowX; ofsPrevY = ofsNowY;
    }
}
