
#import "Tr3.h"

struct MixSet {
    
    Tr3* unflash;
    Tr3* plane;
    Tr3* bits;
    Tr3* op;
    
    int	 mask;
    bool zero;
    
    MixSet();
    
    void set (MixSet &);  
    void bindTr3(Tr3*);
};
