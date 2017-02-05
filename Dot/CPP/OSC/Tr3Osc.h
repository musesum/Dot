
#import "Tr3OscTuio.h" // Tr3Osc(Touch Line Dot Rect)
#import "OscReceiver.h"
#import <unordered_map>
#import "Tr3Types.h"


struct Tr3;
struct Tr3ValTupple;

struct Tr3Osc {
    
    Tr3*root;
    Tr3Osc(Tr3*root_);
    
    OscReceiver	_receiver;
    int _aliveCount;
    KeyTr3 keyTr3;
    
    Tr3* _tr3OscInPort;
    Tr3* _tr3OscInHost;
    Tr3* _tr3OscInMsg;
    
    Tr3* _tr3OscOutPort;
    Tr3* _tr3OscOutHost;
    Tr3* _tr3OscOutMsg;
    
    Tr3* _tr3OscTouchOn;
    Tr3* _tr3OscDotOn;
    Tr3* _tr3OscLineOn;
    Tr3* _tr3OscRectOn;
    
    Tr3*    _acc;
    float*  _accX;
    float*  _accY;
    float*  _accZ;
    
    Tr3*    _msaAccel;
    Tr3ValTupple* _msaXYZ;
    
    Tr3* _note;
    Tr3* _noteNumber;
    Tr3* _noteVelocity;
    Tr3* _noteChannel;
    Tr3* _noteDuration;

    Tr3* _tr3OscManos[MaxOscTouches];
    
    Tr3* _tr3OscTuioPrev[MaxOscTouches];
    float* _tr3OscTuioPrevX[MaxOscTouches];
    float* _tr3OscTuioPrevY[MaxOscTouches];
    float* _tr3OscTuioPrevZ[MaxOscTouches];
    float* _tr3OscTuioPrevF[MaxOscTouches];
    
    Tr3* _tr3OscTuioNext[MaxOscTouches];
    float* _tr3OscTuioNextX[MaxOscTouches];
    float* _tr3OscTuioNextY[MaxOscTouches];
    float* _tr3OscTuioNextZ[MaxOscTouches];
    float* _tr3OscTuioNextF[MaxOscTouches];
    
    //Floats* _oscPrev[MaxOscTouches];
    float* _oscPrevX[MaxOscTouches];
    float* _oscPrevY[MaxOscTouches];
    float* _oscPrevZ[MaxOscTouches];
    float* _oscPrevF[MaxOscTouches];
    
    //Floats* _oscNext[MaxOscTouches];
    float* _oscNextX[MaxOscTouches];
    float* _oscNextY[MaxOscTouches];
    float* _oscNextZ[MaxOscTouches];
    float* _oscNextF[MaxOscTouches];

    int _oscTouchMap[MaxOscTouches];
    int _oscTouchPrev[MaxOscTouches];

    void OscLogMessage(OscMessage* msg);
    void OscTuioAlive(OscMessage* msg);
    void OscTuioSet(OscMessage* msg,OscProfileType type);
    void OscTuio(OscMessage* msg,OscProfileType type);
    void OscTr3(OscMessage* msg);
    void OscAccxyz(OscMessage* msg);
    void OscMsaAccelerometer(OscMessage* msg);
    void OscManosFinger(OscMessage* msg);

    void OscReceiverLog(OscMessage* msg);
    void OscMidiNote(OscMessage* msg);
    int  OscReceiverLoop();    
};
