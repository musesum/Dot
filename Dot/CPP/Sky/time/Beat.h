#import "Tr3.h"

#define BeatMax 99

struct Beat {
    
    string name;
    
    Tr3* rec;		// recording
    Tr3* pause;
    Tr3* play;
    Tr3* sync;
    
    Tr3* span;		// total time between beats	
    Tr3* now;		// current time between beats
    Tr3* clock;		// clock for all beats
    
	
	long beatMax;			 
	long beatNow;		
	long beats[BeatMax];	
    
	long timeLast;	// last measured absolute time
	long timeDelta;	// temporary absolute syncDelta
	long syncDelta;	// synch delta
    
	long recStart;
	long pauseStart;
	long pauseStop;
    
    bool recording;
    bool pausing;
    bool playing;
    bool synching;
    
    Beat();
    
    void bindTr3(Tr3*root, const char*);
    void set(Beat&q);	
    void setRec();
    void setStop();
    void unPause();
    void setTime();
    void go();
    
};