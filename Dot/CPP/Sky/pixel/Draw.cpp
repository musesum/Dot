#import "../pixel/Draw.h"
#import "../main/SkyDefs.h" 
#import <stdlib.h> 
#import <stdio.h> 
#import "math.h"

DrawPoint::DrawPoint(int xx, int yy, int rr, int cc) {
    
	x = xx;
	y = yy;
	r = rr;
	c = cc;
}

Draw::Draw() {
    
    buf=0;
}

void Draw::bindTr3(Tr3* root) {
    
    Tr3*draw    = root->bind("draw");
    
    Tr3*brush   = draw->bind("brush");
	brushType   = brush->bind("type");
	brushSize   = brush->bind("size");
	brushIndex  = brush->bind("index");
	brushHue    = brush->bind("color.hue");
	brushSat    = brush->bind("color.sat");
	brushVal    = brush->bind("color.val");
	brushColorMin = brush->bind("color.min");
	brushColorMax = brush->bind("color.max");

    Tr3*shape = draw->bind("shape");

    dot         = shape->bind("dot",(Tr3CallTo)(&Draw::call_drawEvent),  (void*)this, kDrawEventDot);
    dotNext     = dot->bind("next");
    dotNextX    = (*dotNext)[0];
    dotNextY    = (*dotNext)[1];


	dotRadius   = dot->bind("radius");
	dotColor    = dot->bind("color");			
    
    Tr3*line    = shape->bind("line",(Tr3CallTo)(&Draw::call_drawEvent),  (void*)this, kDrawEventLine);
    linePrev    = line->bind("prev");
    linePrevX   = (*linePrev)[0];
    linePrevY   = (*linePrev)[1];
    lineNext    = line->bind("next");
    lineNextX   = (*lineNext)[0];
    lineNextY   = (*lineNext)[1];

    Tr3*rect    = shape->bind("rect",(Tr3CallTo)(&Draw::call_drawEvent),  (void*)this, kDrawEventRect);
    rectPrev    = rect->bind("prev");
    rectPrevX   = (*rectPrev)[0];
    rectPrevY   = (*rectPrev)[1];
    rectNext    = rect->bind("next");
    rectNextX   = (*rectNext)[0];
    rectNextY   = (*rectNext)[1];
	rectZ       = rect->bind("index");
    
    _noteCircle = draw->bind("note.circle",(Tr3CallTo)(&Draw::call_drawEvent),  (void*)this, kDrawEventNoteCircle);

    _noteCircleNumber    = _noteCircle->bind("number");
    _noteCircleVelocity  = _noteCircle->bind("velocity");
    _noteCircleChannel   = _noteCircle->bind("channel");
    _noteCircleDuration  = _noteCircle->bind("duration");
    _noteCircleSustain   = _noteCircle->bind("sustain",(Tr3CallTo)(&Draw::call_drawEvent), (void*)this, kDrawEventSustain);
    
    _noteSquare = draw->bind("note.square",(Tr3CallTo)(&Draw::call_drawEvent), (void*)this, kDrawEventNoteSquare);
    _noteSquareNumber    = _noteSquare->bind("number");
    _noteSquareVelocity  = _noteSquare->bind("velocity");
    _noteSquareChannel   = _noteSquare->bind("channel");
    _noteSquareDuration  = _noteSquare->bind("duration");
    _noteSquareSustain   = _noteSquare->bind("sustain",(Tr3CallTo)(&Draw::call_drawEvent), (void*)this, kDrawEventSustain);
 }

void Draw::init(Tr3*root, Buf &buf_) {
    
    bindTr3(root);
    buf = &buf_;
    
    for (int i = 0; i<128; i++) {
        noteFlags[i] = kNoteFlagOff;
    }
}

void Draw::go(Buf* buf_) {

    if (!buf_)
        return;	
    prevBuf = buf;
    buf = buf_;

}

void Draw::drawEvent (Tr3*from,void*vp) { 

#define ScaleX(X,P) (int)(((X) * buf->xs)/P->valMax())
#define ScaleY(Y,P) (int)(((Y) * buf->ys)/P->valMax())
    
    switch ((DrawEventType)((Tr3CallInt*)vp)->_int) {
            
        case kDrawEventDot:     circle(*dotNextX * buf->xs,
                                       *dotNextY * buf->ys,
                                       (int)*brushSize,
                                       (int)*brushIndex); break;
            
        case kDrawEventLine:    line (*linePrevX * buf->xs,
                                      *linePrevY * buf->ys,
                                      *lineNextX * buf->xs,
                                      *lineNextY * buf->ys,
                                      (int)*brushSize,
                                      (int)*brushIndex); break;
            
        case kDrawEventRect:   rect(*rectPrevX * buf->xs,
                                    *rectPrevY * buf->ys,
                                    *rectPrevX * buf->xs + *rectNextX * buf->xs,
                                    *rectPrevY * buf->ys + *rectNextY * buf->ys,
                                    (int)*rectZ); break;
        
        case kDrawEventNoteCircle:   noteCircle(*_noteCircleNumber,
                                                *_noteCircleVelocity,
                                                *_noteCircleChannel,
                                                *_noteCircleDuration); break;
            
        case kDrawEventNoteSquare:   noteSquare(*_noteSquareNumber,
                                                *_noteSquareVelocity,
                                                *_noteSquareChannel,
                                                *_noteSquareDuration); break;
            
        case kDrawEventSustain: sustainNotes(); break;
        
            
    }
}


void Draw::goNotes() {
}

void Draw::sustainNotes() {

    if (*_noteCircleSustain ||
        *_noteSquareSustain) {
    
        for (int i=0; i<128; i++) {
                
            if (noteFlags[i] & kNoteFlagTouching)  {     // is currently on
                noteFlags[i] |= kNoteFlagSustain; // include with sustain
            }
        }
    }
    else {
    
        for (int i=0; i<128; i++) {
               if (noteFlags[i] & kNoteFlagSustain)   // is sustained
                   noteFlags[i] ^= kNoteFlagSustain; // remove sustained flag
         }
    }
}

void Draw::noteSquare(int number, int velocity, int channel, float duration) {
    
    
    if (velocity>0) {
        
        noteFlags[number] |= kNoteFlagTouching;
        
        if (*_noteSquareSustain) {
            
            noteFlags[number] |= kNoteFlagSustain;
        }
    }
    
#if 0
    static bool firstTime = true;
    if (firstTime) {
        firstTime = false;
        
         rect(0,0, 100, 100, 255);
    }

#elif 0
    static int testNumber = 31;
    testNumber++;
    if (testNumber>127)
        testNumber=32;
    number = testNumber+4;
    velocity = 92;
    fprintf(stderr, " \n---------                            number:%i  x:%i y:%i  ",number, x, y);
#endif
    static int maxNumber =  0; if (maxNumber < number) maxNumber = number; // 127
    static int minNumber = 99; if (minNumber > number) minNumber = number; // 32
    static int maxVelocity = 127/2.;
    static int maxRadius   = maxVelocity;
    static float octaveRange = (127.-32.)/12.;
    static float scaleRange = 12;
    float ySize = buf->ys - maxRadius;
    float xSize = buf->xs - maxRadius;
    float octave01 = 1.-(float)(number/12) / (octaveRange);
    int scalei = (number%12);
    float scale01 =  (float)scalei / (scaleRange);
    float octaveY = octave01 * ySize;
    float scaleX  = scale01 * xSize;
   
    int y = maxRadius + octaveY; // 3*maxRadius works for some reason
    int x = maxRadius + scaleX;
    int radius = (velocity ? velocity/2 : 5);
    
     static int scale[12] = {0,0,0,0,0,0,0,0,0,0,0,0};
    static int frame = 0;
    if (frame == 300) {
        frame = 0;
        fprintf(stderr, "\n------------- • ");
        for (int i=0; i<12; i++) {
            fprintf(stderr,"%i ",scale[i]);
        }
    }
    frame++;
    scale[scalei]++;
    
    
    float velocity01 = velocity/127.;
    float colorMin = *brushColorMin;
    float colorMax = *brushColorMax;
    
    if (colorMin < colorMax)
        colorMin = colorMax;
    
    float value = colorMin + (colorMax-colorMin) *velocity01;
    
    rect(x-radius/2, y-radius/2, x+radius/2, y+radius/2, value);
}

void Draw::noteCircle(int number, int velocity, int channel, float duration) {
    
    if (velocity>0) {
        
        noteFlags[number] |= kNoteFlagTouching;
        
        if (*_noteCircleSustain) {
            
            noteFlags[number] |= kNoteFlagSustain;
        }
    }
    
    int y = (int)((1-(float)(1+number/12)/14.)*buf->ys);
    int x = (int)((  (float)(1+number%12)/14.)*buf->xs);
    
    int radius = velocity+5;
    
    circle(x, y, radius, 255);
    
}

void Draw::circle(int xx, int yy, int rr, int val) {
    
    if (!buf || rr<1)
		return;
	int x0 = xx-rr;
    int y0 = yy-rr;
	int r2 = (rr*rr);
    int yMax = y0+rr;
    int xMax = x0+rr;
    int xs = buf->xs;
    int ys = buf->ys;
    
	for (int y=y0; y<=yMax; y++) {
        
        for(int x=x0; x<=xMax; x++) {
            int d2 = (x-xx)*(x-xx) + (y-yy)*(y-yy);
            
            if (d2 < r2) {
                
                int xxx = x%xs; if (xxx<0) xxx+=buf->xs;
                int yyy = y%ys; if (yyy<0) yyy+=buf->ys;
                
                *(int*)buf->getXYP(xxx,yyy) = val; // color;
            }
        }
    }
}

void Draw::drawDot(int xx, int yy) {

    if (!buf) 
        return;	
    int bsize = 1; // brush size
	int x= xx%buf->xs;
	int y= yy%buf->ys;
    
	//TODO: need to translate x,y according to tiling space 
	
    if (x >= 1 && x <= buf->xs-bsize &&
        y >= 1 && y <= buf->ys-bsize) {
        
		for	  (int i = 0; i < bsize; i++) {
            
            for (int j = 0; j < bsize; j++) {
                
                *(int*)buf->getXYP(x+i,y+j) = 255; //color;
            }
        }
    }
}

inline void Draw::radius(int centerX, int centerY, int radius, PIX_SIZE value) {
    
    if (!buf || radius<1)
		return;
    
    if (radius==1) {
        
        *(int*)buf->getXYP(centerX,centerY) = value;
        return;
    }
    double r  = (double)radius*2.-1;
    double x0 = (double)centerX - r/2.;
	double y0 = (double)centerY - r/2.;
    double x1 = (double)centerX + r/2.;
    double y1 = (double)centerY + r/2.;
	double r2 = r*r/4.;
    
	for (double y=y0; y < y1; y+=1) {
        
        for(double x=x0; x < x1; x+=1) {
            
            double xd = (x-centerX)*(x-centerX);
            double yd = (y-centerY)*(y-centerY);
            if (xd + yd < r2) {
                
                int xxx = ((int)(x+radius)%buf->xs); if (xxx<0) xxx+=buf->xs;
                int yyy = ((int)(y+radius)%buf->ys); if (yyy<0) yyy+=buf->ys;
                *(int*)buf->getXYP(xxx,yyy) = value; // color;
            }
        }
    }
}

void Draw::line(int x0, int y0, int x1, int y1, int r,  int c) {

    if (!buf) {
        return;
    }
    /* line draws a series of circles
     * with centers from x0,y0 to x1,y1 that have a radius r
     * with x0,y0 as a starting circle's upper left corner
     * so need to shift the centers of starting and ending circles
     */
    x0-=r; y0-=r; /* start circle */
    x1-=r; y1-=r; /* end circle */
    
    int r2 = r*2; /* for endpoint of starting radius */
    
    if (x0<0){x1-=x0; x0=0;}
    if (x1<0){x0-=x0; x1=0;}
    if (y0<0){y1-=y0; y0=0;}
    if (y1<0){y0-=y0; y1=0;}
    
    if (x0+r2>=buf->xs) {x0=(buf->xs-1)-r2; }
    if (y0+r2>=buf->ys) {y0=(buf->ys-1)-r2; }
    if (x1+r2>=buf->xs) {x1=(buf->xs-1)-r2; }
    if (y1+r2>=buf->ys) {y1=(buf->ys-1)-r2; }
    
    int xs = abs(x1-x0)+1;
	int ys = abs(y1-y0)+1;
	int xi = (x0<x1 ? 1 : -1);
	int yi = (y0<y1 ? 1 : -1);
	int xsi = xs*xi*yi;
	int ysi = ys*xi*yi;
	
	if (abs(xs)>abs(ys)) {
        
		if (x0<x1) {
            
			for (int x=x0; x<=x1; x++) {
                
				int yyy = y0+ys*(x-x0)/xsi;
				if (yyy<buf->ys && yyy>=0)
                    radius(x,yyy,r,c);
            }
        }
		else {
            
			for (int x=x0; x>=x1; x--) {
                
				int yyy = y0+ys*(x-x0)/xsi;
				if (yyy<buf->ys && yyy>=0)
                    radius(x,yyy,r,c);
            }
        }
    }
	else {
        		
		if (y0<y1) {
            
			for (int y=y0; y<=y1; y++) {
                
				int xxx = x0+xs*(y-y0)/ysi;
				if (xxx<buf->xs && xxx>=0)
                    radius(xxx,y,r,c);
            }
        }
		else {
            
			for (int y=y0; y>=y1; y--) {
                
				int xxx = x0+xs*(y-y0)/ysi;
				if (xxx<buf->xs && xxx>=0)
                    radius(xxx,y,r,c);
            }
        } 
    }
}

void Draw::rect(int x0, int y0, int x1, int y1, int value) {

    if (!buf) 
        return;
    
    while(x0<0 || x1<0) {
        
		x0 += buf->xs;
		x1 += buf->xs;
    }
	while (y0<0 || y1<0) {
        
		y0 += buf->ys;
		y1 += buf->ys;
    }    

	int xx0 = MIN(x0,x1);
	int xx1 = max(x0,x1);
	int yy0 = MIN(y0,y1);
	int yy1 = max(y0,y1);
	xx1 = min (buf->xs, xx1);
	yy1 = min (buf->ys, yy1);
    
	int v= value%256; if (v<0) v += 256;
    
	for	(int y = yy0; y <yy1; y++) {
        
        for (int x = xx0; x <xx1; x++) {	
            
            *(int*)buf->getXYP(x%buf->xs, y%buf->ys) = v;
        }
    }
}
