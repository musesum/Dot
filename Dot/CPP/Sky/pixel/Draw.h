#import "Tr3.h"
#import "../pixel/Univ.h"
#import "../pixel/pixdefs.h"

struct DrawPoint {
    int x,y,r,c;
    DrawPoint(int,int,int,int);	
};

typedef enum {
    
	kDrawEventDot,
	kDrawEventLine,
	kDrawEventRect,
    kDrawEventNoteCircle,
    kDrawEventNoteSquare,
    kDrawEventSustain,
}
DrawEventType;

typedef enum {
    kNoteFlagOff,
    kNoteFlagTouching = 1<<0,
    kNoteFlagSustain = 1<<1,
    
} NoteFlag;

struct Draw {
    
    Tr3* brushType;
    Tr3* brushSize;
    Tr3* brushIndex;
    Tr3* brushHue;
    Tr3* brushSat;
    Tr3* brushVal;
    Tr3* brushColorMin;
    Tr3* brushColorMax;
    
    Tr3* dot;           // draw the dot
    
    Tr3* dotNext;
    float* dotNextX;    // pointer to dotNextX->val->vals[0]->num
    float* dotNextY;    // pointer to dotNextX->val->vals[1]->num
    
    Tr3* dotRadius;     // dot size
    Tr3* dotColor;      // dot index color
    
    Tr3* linePrev;      // start of line
    float* linePrevX;   // pointer to linePrev->val->vals[0]->num
    float* linePrevY;   // pointer to linePrev->val->vals[1]->num
    
    Tr3* lineNext;      // end of line
    float* lineNextX;   // pointer to lineNext->val->vals[0]->num
    float* lineNextY;   // pointer to lineNext->val->vals[1]->num

    Tr3* rectPrev;      // start of rect
    float* rectPrevX;
    float* rectPrevY;
    
    Tr3* rectNext;      // end of rect
    float* rectNextX;
    float* rectNextY;
  
    Tr3* rectZ;         // rect index color
     

    Tr3* _noteCircle;
    Tr3* _noteCircleNumber;
    Tr3* _noteCircleVelocity;
    Tr3* _noteCircleChannel;
    Tr3* _noteCircleDuration;
    Tr3* _noteCircleSustain;
    
    Tr3* _noteSquare;
    Tr3* _noteSquareNumber;
    Tr3* _noteSquareVelocity;
    Tr3* _noteSquareChannel;
    Tr3* _noteSquareDuration;
    Tr3* _noteSquareSustain;
    
    Buf* buf;
    Buf* prevBuf;
    
    int noteFlags[128];
    Tr3CallbackEvent(Draw, drawEvent);
    
    Draw();
    
    void init(Tr3*root, Buf &buf_);
    void bindTr3(Tr3*root);
    
    void go(Buf*buf_);
    void goNotes();
    void sustainNotes();
    void noteCircle(int number, int velocity, int channel, float duration);
    void noteSquare(int number, int velocity, int channel, float duration);
    void circle(int xx, int yy, int rr, int val);
    void rect  (int xx, int yy, int xxs, int yys, int value);
    
    inline void radius(int centerX, int centerY, int radius, PIX_SIZE value);
    void drawDot (int xx, int yy);
    void line  (int x0, int y0, int x1,  int y1, int r, int c);
    
    void circle(int xx, int yy,    // center point
                int rr,            // radius
                PIX_SIZE val);      // value

    
};
