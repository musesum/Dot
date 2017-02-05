#import "../main/SkyDefs.h"
#import "Tr3.h"

struct Shift {
    
    Tr3* on;
    Tr3* reverse;
    
    Tr3* sum;
    float* sumX;
    float* sumY;
    
    Tr3* ofs;
    float* ofsX;
    float* ofsY; // Floats* ofss;
    
    Tr3* add;
    float* addX;
    float* addY; // Floats* adds;
    
    int deltaX;
    int deltaY;
    int revNow;
    
    float sumPrevX; float sumPrevY;
    float ofsPrevX; float ofsPrevY;
    
    float sumNowX;  float sumNowY;
    float ofsNowX;  float ofsNowY;
    float addNowX;  float addNowY;
    
    Shift();
    
    void bindTr3(Tr3*root, const char*);
    void getDelta(int&dx,int&dy);
    void go();
    
};



