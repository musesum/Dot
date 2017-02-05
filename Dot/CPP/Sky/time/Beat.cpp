#import <stdlib.h>
#import "../time/Beat.h"
#import "../main/SkyDefs.h"
#import "../time/SkyClock.h"


Beat::Beat() {

	recording = false;
	playing	  = false;
	synching  = false;
	pausing	  = false;
    
	beatMax	  = 0;
	beatNow	  = 0;
	timeLast  = 0;
	syncDelta = 0;
    
	pauseStart= 0;
	pauseStop = 0;
    
}
void Beat::bindTr3(Tr3*root, const char* label) {
     
    name = label;
    Tr3*beat = root->bind("time.beat");
    beat = beat->bind(label);
    
	rec	 = beat->bind("rec" );
	pause= beat->bind("stop");		// uses relative tree search to find label
	play = beat->bind("play");
	sync = beat->bind("sync");
    
	span = beat->bind("span");
	now	 = beat->bind("now" );
	clock = beat->bind("clock");
}
void Beat::set (Beat &q) {

	name =q.name ;
	rec	 =q.rec	 ;
	pause=q.pause;		// uses relative tree search to find label
	play =q.play ;
	sync =q.sync ;
	span =q.span ;
	now	 =q.now	 ;
	clock=q.clock;
    
	recording = q.recording;
	playing	  = q.playing;
	synching  = q.synching;
	pausing	  = q.pausing;
    
	beatMax	  = q.beatMax;	  
	beatNow	  = q.beatNow;	  
	timeLast  = q.timeLast;  
	syncDelta = q.syncDelta; 
    
	pauseStart= q.pauseStart;
	pauseStop = q.pauseStop; 
}
void Beat::setRec() {
    
	if (!recording || pausing) {
        
		recording = true;
		playing   = false;
		pausing   = false;
        
		recStart  = skyClock.getTime();
		beats[0]  = 0;
		beats[1]  = 1;  // kludge
		beatMax	  = 1;
    }
	else {	// new beat	
		
        int newBeat	= skyClock.getTime() - recStart;
		
        if (newBeat > 20) { // 500 beats per sec 			  
            
			beats[beatMax] =  newBeat;
			beatMax++;
        }
    }
}
void Beat::setStop() {

	if (!pausing)
    {
		pausing  = true;
		pauseStart = skyClock.getTime();
    }
}
void Beat::unPause() {

	pausing  = false;
	pauseStop  = skyClock.getTime();
}
inline int minAbs(int x, int y) {

	if (abs(x) < abs (y))
        return x;
	else return y;
}
void Beat::setTime() {

	timeDelta = skyClock.getTime() -timeLast;
	timeLast  = skyClock.getTime();
	clock->setNow((long)*time + timeDelta + syncDelta);
	syncDelta = 0;
}															 
void Beat::go() {
 
	if (pausing)
		return;
	setTime();
	if (playing) {
        if ((int)*clock > beats[beatNow])	{// new beats?
			while (beats[beatNow] < (long)*time) {
				beatNow++;
                if (beatNow>beatMax) { // past end?
					beatNow=1;		// start at beginning
					clock->setNow((int)*clock - beats[beatMax]);	// adjust relative time
                }
				span->setNow(beats[beatNow] - beats[beatNow-1]);
            }
        }
		int newNow = (int)*clock- beats[beatNow-1];
		now->setNow(max(0,newNow));
    }
    
}
