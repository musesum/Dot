#import "Tr3.h"
#import "../color/Rgbs.h"

struct Cycle {
    
    static int count;
    
    Tr3* inc;
    Tr3* ofs;
    Tr3* div;//divisor for offset
    int now;
    
    Cycle();
    
    void bindTr3(Tr3*root);
    bool shift(Rgbs&rgbs);
    bool goCycle(Rgbs&rgbs);
    void setCycle(Cycle&);
};
