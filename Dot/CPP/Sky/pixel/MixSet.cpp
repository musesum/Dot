#import <string.h>
#import <stdlib.h>
#import "MixSet.h"

MixSet::MixSet(){
}
void MixSet::set (MixSet &q) {
    
	op	  = q.op;
	plane->setNow((float)*q.plane);
	bits ->setNow((float)*q.bits);
	mask  = q.mask;
	zero  = q.zero;
}
void MixSet::bindTr3(Tr3*tr3) {
    
    Tr3*mix = tr3->bind("mix");
    unflash = mix->bind("unflash");
    plane   = mix->bind("plane");
    bits    = mix->bind("bits");
    op      = mix->bind("op");
}
