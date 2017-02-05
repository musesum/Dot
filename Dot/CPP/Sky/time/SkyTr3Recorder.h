#import <string>
#import <vector>
#import <iterator>
#import <unordered_map>
#import "tr3.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

struct Tr3TimeFrame { 
  
    Tr3*        _tr3;
    float       val;
    long double _time;  
    int         _frame;
    
    Tr3TimeFrame(Tr3*,long double,int);
    void setVal();
};

struct Tr3Path { 
    
    Tr3    *_tr3;  
    string _path; 
    Tr3Path (Tr3*tr3, char*path);
};

//---------------------------------------------------

typedef enum {
    
    kRecorderUndef,
    kRecorderRecord,
    kRecorderPause,
    kRecorderPlayback,
    kRecorderRewind,
    kRecorderToend,
    kRecorderErase,
}   RecorderState;

typedef vector<Tr3TimeFrame*> Tr3TimeFrames;
typedef unordered_map<int,string> Tr3Paths;
struct Lock {
    int _count;
        Lock();
    void push();
    void pop();
    bool locked();
};
struct SkyTr3Recorder {
    
    Tr3TimeFrames _tr3TimeFrames; 
    Tr3Paths      _tr3Paths;
 
    RecorderState _state;
    Lock lock;
    // time based recording and playback

    long double _startTime;
    long double _deltaTime;
     
    // frame based recording and playback
    int _frame; // set by app calling goRecorder(int)
    int _startFrame;
    int _deltaFrame;

    
    // position within Tr3TimeFrames
    int _index;
    
    
    Tr3* _tr3Filename;
    Tr3* _tr3Useframe;
    Tr3* _tr3Loop;
    
    SkyTr3Recorder(const char*parent);
    void init(const char*parent);
    
    Tr3CallbackEvent(SkyTr3Recorder, recorderState)
    Tr3CallbackEvent(SkyTr3Recorder, recorderEvent)
    
    // playback event locked to either frame or time
    void recorderPlayback();
    
    // set state
    void record(); 
    void pause();
    void playback();
    void rewind();
    void toend();
    void erase();
    
    void goRecorder(int frame_);
    void addPaths();   
    void startRecording();
    
};
