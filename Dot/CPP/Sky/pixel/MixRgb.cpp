#import <stdlib.h>
#import "MixRgb.h"

MixRgb::MixRgb() {
    
	pixCount = 1;
}
void MixRgb::init(int xs, int ys, int univSurfs) {
    
	pixCount = univSurfs;
    int i=0;
	for (; i<pixCount; i++)
		buf[i].init(xs,ys,4);
    
	for (;i<FaceMax; i++)
		buf[i].clear();
}
void MixRgb::go() {
    
	for (int i=0; i<pixCount; i++) {
		px[i] = &buf[i];
    }
}
