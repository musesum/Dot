#import "Tr3.h"

#define DeltaMax 30

struct SkyClock {
    
    long long time64;
    long long freq64;
    
    double 	timeFps;		// this is frames of video per second
    double  deltaAve;
    
    int deltas[DeltaMax]; // delta msec ticks between last n frames
    int deltaTotal;
    
    int frameNum;
    int timeDelta;
    
    long timeFirst;	// starting millisec
    long timeNow;	// current millisec
    long timeLast;	// previous millisec
    
    long lockTime;	// first millisec of locking time
    long lockFrame;	// first frame of locking time
    
    void pause();
    void unpause();
    bool pausing;
    unsigned int pausetime;
    unsigned int pausetotal;
    
    Tr3 *status;	// status line text for frames per sec
    
    Tr3 *frame;	// frame number
    Tr3 *fps; 	// frames per second for executing rule
    Tr3 *fpsNow;	// current
    
    Tr3 *lock;		// whether to lock render to framerate 
    Tr3 *lockFps;	// numerator for frames per second
    Tr3 *lockBase;	// denominator for frames per second
    
    SkyClock();
    void bindTr3(Tr3*root);
    void init(Tr3*root);
    unsigned long getTime();
    unsigned long getWinTime();
    int		getFrame();
    double	getFps();
    bool go();
};

extern SkyClock skyClock;

