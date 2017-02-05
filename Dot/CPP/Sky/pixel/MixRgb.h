
#import "../pixel/Buf.h"
#import "../pixel/FaceDefs.h"

struct MixRgb {
    
    Buf buf[FaceMax];
    Buf* px[FaceMax];
    int pixCount;
    
    MixRgb();
    
    void init(int xs,int ys, int univSurfs);
    
    void go();
};
