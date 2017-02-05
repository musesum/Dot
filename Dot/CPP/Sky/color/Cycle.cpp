#import <stdlib.h>
#import "../color/Cycle.h"
#import "../time/SkyClock.h"
#import "OsGetTime.h"

Cycle::Cycle() {
    
	now = 0;
    
}
void Cycle::bindTr3(Tr3*root) {
    
    Tr3*pc = root->bind("pal.cycle");
	inc = pc->bind("inc"); // Absolute main.tree position
	ofs = pc->bind("ofs");
	div = pc->bind("div");
}
bool Cycle::goCycle(Rgbs&final) {
    
    // get Tr3 values
    float ofsNow = (float)*ofs;
    float incNow = (float)*inc;
    float divNow = (float)*div;
    float increment = incNow/divNow;
    if (increment != 0) {
        ofs->setNow(ofsNow + increment);
    }
    return shift(final);
}
bool Cycle::shift (Rgbs&final) {

    static bool shifting = false;
    if (shifting ||
        (!*ofs && !*inc) ||
        (!final._rgbNow)) {
        return false;
    }
    shifting = true;
    
    float offset = (float)*ofs;
    int  d = abs((int)*ofs) % final._rgbNow;
    int ii = ((int)offset < 0 ? d : final._rgbNow-d);
    
    Rgb* ptem = (Rgb*) malloc (final._rgbNow*sizeof(Rgb));
    Rgb* pj = ptem;
    Rgb* pi = final._rgbArray+ii;
    int i=ii;
    for (; i<final._rgbNow; i++, pi++,pj++) 
    {
        pj->r = pi->r;
        pj->g = pi->g;
        pj->b = pi->b;
    }
    
    pi = final._rgbArray;
    
    for (i=0; i<ii; i++, pi++,pj++)
    {
        pj->r = pi->r;
        pj->g = pi->g;
        pj->b = pi->b;
    }
    free (final._rgbArray);
    final._rgbArray = ptem;
    final._rgbMax = final._rgbNow; // auto shrunk, as well
    shifting = false;
    return true;
}
void Cycle::setCycle(Cycle &q) {

	inc->setNow((float)*q.inc);	
	ofs->setNow((float)*q.ofs);	
	now	  = q.now;
}
