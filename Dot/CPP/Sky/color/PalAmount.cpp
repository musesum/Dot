#import <stdlib.h>
#import "PalAmount.h"

PalAmount::PalAmount () {

	init();
}
void PalAmount::init() {
    
    muy	  = 1;	// multiplyer
	div   = 1;	// divisor
	deflt = 0;	// ==0 use parent, otherwise use this
	more  = 0;	// range val > 0
	less  = 257;// range val < 257
	
}
void PalAmount::equals(PalAmount&q) {
    
	muy	  = q.muy;
	div   = q.div;	
	deflt = q.deflt;	
	more  = q.more;	
	less  = q.less;
}
bool PalAmount::divide(int i)  {
    
	if (i != div && div >0) {
        
		div = i;
		return 1;
    }
	return 0;
}
bool PalAmount::multiply(int i) {
	
	if (i != muy && muy > 0) {
		muy = i;
		return 1;
    }
	return 0;
}
bool PalAmount::size(int i) {
    
	if (i!=deflt) {
		deflt= i; // palette size, ==0 to calc from parent;
		return 1;
    }
	return 0;
}
bool PalAmount::greaterThan(int i) {
	
    if (i != more) {
        
		more = i;
		if (more>deflt && deflt!=0)	 // conflicts with active default 
			deflt=more+1;			 // so, upgrade default
		return 1;
    }
	return 0;
}
bool PalAmount::lessThan(int i) {
    
	if (i != less) {
        
		less = i;
		if (less<deflt && deflt!=0)	// conflicts with active default
			deflt=0;				// so, upgrade default
		return 1;
    }
	return 0;
}
bool PalAmount::inRange(int val) {
    
	if (abs(val)>more && abs(val)<less)
        
        return 1;
	else return 0;
}

