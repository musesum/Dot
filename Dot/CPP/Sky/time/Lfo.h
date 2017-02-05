#import "Tr3.h"

struct Lfo {
    
    Tr3* val;
    Tr3* type; 
    Tr3* rad; 
    Tr3* amp;
    Tr3* time;
    Tr3* count;
    
    int first;
    int last;
    
    Lfo();
    
    void set(Lfo &q); 
    void bindTr3(Tr3*root, const char*);
    void go();
    
};