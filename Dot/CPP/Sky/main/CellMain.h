#import "Tr3.h"
#import "../pixel/Draw.h"
#import "../pixel/Pic.h"

struct CellMain {
    
    CellMain(Tr3*root, void*buf,int xs, int ys, int zs);
    int init(Tr3*root, void*buf,int xs, int ys, int zs);
	
	bool play();
	bool pause();
	bool step();
    bool paused;

    void* go8();
    void goPixelBuffer(void*pixelBuffer);
     
	void done();
    bool exiting; 

    Tr3* clockFps;
   	float oldFps;
    
    Draw draw;		// draw a primative 
	Pic pic;		// Pic process images and rules       
};

//extern CellMain cellMain;