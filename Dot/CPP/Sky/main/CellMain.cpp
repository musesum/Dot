#import "CellMain.h"
#import "../time/SkyClock.h"
#import "CellRules.h"

SkyClock skyClock;

CellMain::CellMain(Tr3*root,void*buf,int xs, int ys, int zs) {

	exiting = false;
    oldFps = 0;
    init(root, buf, xs, ys, zs);
}

int CellMain::init(Tr3*root,void*buf,int xs, int ys, int zs) {
	
    Tr3* sky = root->bind("sky");
    clockFps = sky->bind("time.clock.fps");
    paused = false;
    skyClock.init(sky);
    pic.init(sky,buf,xs,ys,zs);
    draw.init(sky,pic.univ.buf[0]);
    oldFps = *clockFps;
	return 0;
}

bool CellMain::pause() {
    
	if (*clockFps)	{
        
		oldFps = *clockFps;
		clockFps->setNow((float)0);
    }
	else{
		return play();
    }
	return true;
}

bool CellMain::step() {

	return true;
}

bool CellMain::play() {

	clockFps->setNow(oldFps);
	return true;
}

void CellMain::goPixelBuffer(void*pixelBuffer) { 
    
    static int count=0;
	count++;
	
	skyClock.go();
    draw.go(pic.univ.bufPrev);	// flip draw buffer
    if (!paused) {
        pic.goPixelBuffer(pixelBuffer);
    }
}

void* CellMain::go8() {
    
    static int count=0;
	count++;
	
	skyClock.go();
    draw.go(pic.univ.bufPrev);	// flip draw buffer
    if (!paused) {
        pic.go8();
    }
    return (void*)(pic.mix.buf[0].buf);
}
 
void CellMain::done() {

	if (!exiting) {
		exiting = true;
    }
}

