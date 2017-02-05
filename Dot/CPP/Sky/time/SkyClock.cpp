#import <stdlib.h>
#import <stdio.h>
#import "SkyClock.h"
#import "OsGetTime.h"

unsigned int getMsecSinceStartTime() {
    
    //TODO: this kludge must be fixed very soon!
    
    static long double firstTime = OSGetTime(); 
    long double thisTime = OSGetTime();
    unsigned int t = (unsigned int) ((thisTime-firstTime)*1000.0); // convert to milliseconds
    return t;
}
SkyClock::SkyClock() {
    
	frameNum	= 0;
	timeFps		= 0;	 
	timeDelta	= 0;
    
	timeNow		= 0;   
	timeLast	= 0;
    
	lockTime	= 0;
	lockFrame	= 0;
    
	pausing		= false;
	pausetime	= 0;
	pausetotal	= 0;
}

void SkyClock::bindTr3(Tr3*root) {
    
    Tr3*clock=root->bind("time.clock");
	frame	= clock->bind("frame");
	fps		= clock->bind("fps");
	fpsNow	= clock->bind("fps.now");
	lock	= clock->bind("lock");
	lockFps	= clock->bind("lock.fps");
	lockBase= clock->bind("lock.base");
	status	= clock->bind("status");
}
void SkyClock::init(Tr3*root) {
    
    bindTr3(root);
    
	timeFirst = getWinTime();
	timeLast  = getWinTime();
	frameNum = 0;
	if (*lock) {
		lockFrame = frameNum;
		lockTime = timeFirst;
    }
	else lockTime = 0;
	for (int i=0; i<DeltaMax; i++)
		deltas[i] = 0;
    
	deltaAve = 0.;
	deltaTotal = 0;
    
	pausing		=false;
	pausetime	=0;
	pausetotal	=0;
}
void SkyClock::pause() {

	if (pausing)
		return;
	pausing = true;
	pausetime = getMsecSinceStartTime();
}
void SkyClock::unpause() {

	if (!pausing)
		return;
	pausing = false;
	pausetotal += getMsecSinceStartTime()-pausetime;
	// pausetotal set back to 0 by ::go()
}
unsigned long SkyClock::getTime() {

	if (*lock) {
        
		if (lockTime==0) {
            
			lockFrame = frameNum;
			lockTime = timeNow;
			return timeNow;
        }
		return lockTime + ((frameNum-lockFrame)*(float)*lockFps)/(float)*lockBase;
    }
	else {
		lockTime = 0;
    }
	return timeNow;
}
unsigned long SkyClock::getWinTime() {
    
	return getMsecSinceStartTime(); 
}
int SkyClock::getFrame() {
    
	return frameNum;
}
double SkyClock::getFps() {

	return timeFps;
}
bool SkyClock::go () {

	unpause();
	timeNow   = getMsecSinceStartTime();
    
	if (*lock) {
        
		if (lockTime==0) {
            
			lockFrame = frameNum;
			lockTime = timeNow;
        }
		float deltaTime = (float)(timeNow-lockTime);
		float base = (float) *lockBase;
		float factor = (float)*lockFps/base/1000.0;
		unsigned int targetFrame = lockFrame+(unsigned int)(deltaTime*factor);
        
		if (targetFrame < frameNum)
			return false;
    }

	timeDelta = timeNow -timeLast -pausetotal;
	if (pausetotal != 0) 
		pausetotal  = 0;
    
	unsigned int di = frameNum%DeltaMax;					// get index for array of n deltas
	deltaTotal -= deltas[di];
	deltaTotal += timeDelta;	
	deltas[di] = timeDelta;	
    
	deltaAve = (double)deltaTotal/(double)DeltaMax;		// update average with different
	
	if (deltaAve > 0.)
		timeFps = 1000./deltaAve;
	else 
		timeFps = 1.;
    
	if ((di&3)==0) { // every 4th frame update status
    
		char buf[30];
		sprintf(buf,"%5.1f fps",timeFps);
		status->setNow((char*)&buf);
    }
    //____
	timeLast = timeNow; // changed 9/2/04 ws
	frameNum++;
	frame->setNow(frameNum);
	return true;
}

