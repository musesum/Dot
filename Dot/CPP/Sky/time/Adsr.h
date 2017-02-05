#import "Tr3.h"

typedef enum {
    
	AdsrWait,
	AdsrAttack,
	AdsrDecay,
	AdsrSustain,
	AdsrRelease,
}   AdsrState;

struct Adsr {
    
    Tr3* aAmp; Tr3* aDur;
    Tr3* dAmp; Tr3* dDur;
    Tr3* sAmp; Tr3* sDur;
    Tr3* rAmp; Tr3* rDur;
    
    Tr3* on;  
    Tr3* count;
    Tr3* value;
    
    int			 zapVal;		// staring point for attack	(to smooth interrupted attacks)
    int atkTime, atkVal;		// attack time, last value
    int decTime, decVal;		// decay time, last value
    int susTime, susVal;		// sustain time, last value
    int relTime, relVal;		// release time, last value
    
    AdsrState	state;		// which leaf to calculate after trigger
    
    Adsr();
    void bindTr3(Tr3*root);
    void set(Adsr &q);	 
    void go();
    
    inline void wait();	
    inline void attack();
    inline void decay();
    inline void sustain();
    inline void release();
    
};									
