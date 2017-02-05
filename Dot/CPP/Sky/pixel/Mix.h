#import "Tr3.h"
#import "../pixel/Buf.h"
#import "../pixel/MixSet.h"
#import "../pixel/FaceMap.h"
#import "SkyDefs.h"

typedef enum {
    
    MixZero=0,
    MixMov,
    MixAdd,
    MixSub,
    MixAnd,
    MixOr,
    MixXor,
    MixAve,
    MixEdge,
    MixMinus,
}
MixOp;

struct Univ;

struct Mix {
    
    //MixSet mixSet;
    MixSet* mx;
    
    Tr3*editPlane;
    Tr3*editPage;
    Tr3*editBits;
    
    Buf buf[FaceMax];
    Buf* px[FaceMax];
    int pixCount;
    
    Mix();
    
    void bindTr3(Tr3*root);
    void initMix(Tr3*root, int xs,int ys,int zs, int univSurfs);

    Tr3CallbackEvent(Mix,mixZero);
    Tr3CallbackEvent(Mix,mixPlane);
    Tr3CallbackEvent(Mix,mixBits);
    Tr3CallbackEvent(Mix,mixPlus);
    Tr3CallbackEvent(Mix,mixEquals);
    
    byte edge(Univ&univ,int i);
    void goMix(Univ&univ);
    
  };