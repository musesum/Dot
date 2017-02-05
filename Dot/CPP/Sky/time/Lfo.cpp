#import <math.h>
#import "Lfo.h"

Lfo::Lfo() {
    
	first = 0;
	last  = 0;
}
void Lfo::bindTr3(Tr3*root, const char*label) {
    
	Tr3*lfo = root->bind("time.lfo");
	val     = lfo->bind(label);
	type    = val->bind("type");
	rad     = val->bind("radians");
	amp     = val->bind("amp");
	time    = val->bind("cime");
	count   = val->bind("count");
    
	first = last = *count; 
}
void Lfo::set(Lfo &q) {

	val  ->setNow((float)*q.val);
	type ->setNow((float)*q.type);
	rad  ->setNow((float)*q.rad);
	amp  ->setNow((float)*q.amp);
	time ->setNow((float)*q.time );
	count->setNow((float)*q.count);
    
	first= q.first;
	last = q.last;
}
void Lfo::go() {
 
	if (last == (int)*count)
		return;
    
	if ((int)*time == 0) {
        
		val->changeValNow(0); 
		return;
    }
    
	static double pi = 3.1415926535;
	last = *count;
    int itime = *time;
	double modTime = (double)((last - first)% itime); 
	double ratio   = modTime / (double) *time;
	double ampl	   = 0;
    
	switch ((int)*type) {
            
        case 1:	ampl = sin(ratio*pi*(float)*rad) * (double)(float)*amp;     break;
        case 2:	ampl = cos(ratio*pi*(float)*rad) * (double)(float)*amp;     break;
            
        case 3:	ampl =  ( ratio < 0.5  ?  ratio * 2.0 * (float)*amp
                         : (float)*amp -((ratio-0.5) * 2.0 * (float)*amp));	break;
            
        case 4:	ampl = ratio * (float)*amp;                                 break;
        case 5:	ampl = ((double)amp->valMax())-(ratio * (float)*amp);		break;
    }
	val->changeValNow((float) ampl); 
}

