
#import "SkyTr3Recorder.h"
#import "OsGetTime.h"
#import "SkyTr3Root.h"

#define PrintTr3Recorder(...) //DebugPrint(__VA_ARGS__)

Tr3TimeFrame::Tr3TimeFrame(Tr3*tr3_, long double time_, int frame_) { 

    _tr3 = tr3_;
     val = *tr3_;
    _time = time_;
    _frame = frame_;
}

void Tr3TimeFrame::setVal() {
    Tr3ValScalar *v = (Tr3ValScalar*)_tr3->val;
    v->setFloat(val);
    _tr3->bang();
}


Tr3Path::Tr3Path (Tr3*tr3_, char*path_) {

    _tr3  = tr3_;
    _path = path_;
}


//---------------------------------------------------

//TODO: make this work with mutex

Lock::Lock() {
    
    _count = 0;
}

void Lock::push() {
    
    _count++;
}

void Lock::pop() {

    if (_count>0) {
        _count--;
    }
}

bool Lock::locked() {
    
    return _count>0;
}
//---------------------------------------------------

SkyTr3Recorder::SkyTr3Recorder(const char*parent) {

    init(parent);
}

void SkyTr3Recorder::init(const char*parent) {
    
    _startTime  = 0;
    _deltaTime  = 0;
    _startFrame = 0;
    _deltaFrame = 0;
    _index      = 0;
    _state      = kRecorderRewind;
    
    Tr3*recorder = SkyRoot->bind(parent);
    _tr3Filename = recorder->bind("filename");    
    _tr3Useframe = recorder->bind("useframe");    
    _tr3Loop     = recorder->bind("loop");    
    
    recorder->bind("record"  ,(Tr3CallTo)(&SkyTr3Recorder::call_recorderState), (void*)this, kRecorderRecord  );    
    recorder->bind("pause"   ,(Tr3CallTo)(&SkyTr3Recorder::call_recorderState), (void*)this, kRecorderPause   );    
    recorder->bind("play"    ,(Tr3CallTo)(&SkyTr3Recorder::call_recorderState), (void*)this, kRecorderPlayback);    
    recorder->bind("rewind"  ,(Tr3CallTo)(&SkyTr3Recorder::call_recorderState), (void*)this, kRecorderRewind  );    
    recorder->bind("toend"   ,(Tr3CallTo)(&SkyTr3Recorder::call_recorderState), (void*)this, kRecorderToend   );   
    recorder->bind("erase"   ,(Tr3CallTo)(&SkyTr3Recorder::call_recorderState), (void*)this, kRecorderErase   );   
    recorder->bind("event"   ,(Tr3CallTo)(&SkyTr3Recorder::call_recorderEvent), (void*)this, kRecorderUndef   ); 
}

#pragma app loop

void SkyTr3Recorder::goRecorder(int frame) {
    
    _frame = frame;
    
    switch (_state) {
            
        case kRecorderPlayback: recorderPlayback();  break;
        default:                                     break;
    }
}

#pragma event state

void SkyTr3Recorder::recorderPlayback() {
    
    // playback event locked to either frame or time
    
    if (_state != kRecorderPlayback) 
        return;
    
    long double deltaTime = OSGetTime() - _startTime;
    
    bool useFrame = *_tr3Useframe;
    int size = _tr3TimeFrames.size();
    int deltaFrame = _frame -_startFrame;
    string fullPath; 

    for (; _index < size; _index++) {
        
        Tr3TimeFrame*tr3TimeFrame = _tr3TimeFrames[_index];
        
        if (useFrame) {
            
            if (tr3TimeFrame->_frame <= deltaFrame) {
                    
                tr3TimeFrame->setVal();
                
                //Debug(tr3TimeFrame->_tr3->fullPath(fullPath);)
                PrintTr3Recorder("SkyTr3Recorder::recorderPlayback index:%i frame:%i delta:%i %s:%.2f\n",_index,tr3TimeFrame->_frame,deltaFrame, 
                                 fullPath.c_str(),(float)*(tr3TimeFrame->_tr3));
                
            } 
            else {
                break;
            }
        }
        else {
            if (tr3TimeFrame->_time <= deltaTime) {
                
                tr3TimeFrame->setVal();
                
                //Debug(tr3TimeFrame->_tr3->fullPath(fullPath);)
                PrintTr3Recorder("SkyTr3Recorder::recorderPlayback index:%i time:%.1f delta:%.1f %s:%.2f\n",
                                 _index,tr3TimeFrame->_time,deltaTime,
                                 fullPath.c_str()(float)*(tr3TimeFrame->_tr3));
            } 
            else {
                break;
            }
        }
    }
    if (_index>=size) {
        
        if (*_tr3Loop) {

            rewind();
        }
        else {
            pause();
        }
    }
}

void SkyTr3Recorder::recorderEvent (Tr3*from,void*vp) {
    
    // callback from Tr3.recorder.event @^
    
    
    if (_state == kRecorderRecord) {
        
        _deltaTime = OSGetTime() - _startTime;
        int deltaFrame = _frame-_startFrame;
        Tr3TimeFrame*tr3TimeFrame  = new Tr3TimeFrame(from,_deltaTime,deltaFrame);
        _tr3TimeFrames.push_back(tr3TimeFrame);

        Debug(string fullPath = from->parentPath();)
        PrintTr3Recorder("SkyTr3Recorder::recorderEvent %s:%.2f %p\n",fullPath.c_str(),(float)*from,tr3TimeFrame);
       // PrintTr3Recorder("rec[%i]=%i ",(int)_tr3TimeFrames.size(),(int)deltaFrame);
    }
}

#pragma recoder state

void SkyTr3Recorder::recorderState (Tr3*from,void*vp) {
    
    // callback from Tr3 script
    RecorderState state = (RecorderState)((Tr3CallInt*)vp)->_int;
    PrintTr3Recorder("SkyTr3Recorder::recorderState %i\n",state); 

    switch (state) {
            
        case kRecorderRecord:   record();   break;
        case kRecorderPause:    pause();    break;
        case kRecorderPlayback: playback(); break;
        case kRecorderRewind:   rewind();   break;
        case kRecorderToend:    toend();    break;
        case kRecorderErase:    erase();    break;
        default:                            break;
    }
}

void SkyTr3Recorder::record() {
    
    PrintTr3Recorder("SkyTr3Recorder::record\n"); 
    lock.push();
    
     if (_state != kRecorderRecord) {
        
         if (_state != kRecorderPause) {
             
             _deltaFrame = 0;
             _deltaTime = 0;
             _startTime  = OSGetTime(); 
             _startFrame = _frame;  
             
         }
         else {
        //adjust time frames as though uninterrupted
        _startTime  = OSGetTime() - _deltaTime; 
        _startFrame = _frame    - _deltaFrame;  
         }
        _state = kRecorderRecord;
    }
    lock.pop(); 
}

void SkyTr3Recorder::pause() {
    
    PrintTr3Recorder("SkyTr3Recorder::pause\n"); 

    lock.push();
    
    if (_state != kRecorderPause) {
        
        
        _state = kRecorderPause; 
        
        _deltaTime  = OSGetTime() - _startTime;
        _deltaFrame = _frame    - _startFrame;
    }
    lock.pop();
}

void SkyTr3Recorder::playback() {

    PrintTr3Recorder("SkyTr3Recorder::playback\n"); 
    
    lock.push();
    if (_tr3TimeFrames.size()>0) {
        
        _state = kRecorderPlayback; 
        _startFrame = _frame;
        _startTime = OSGetTime();
        _index = 0;
    }
    lock.pop();
}

void SkyTr3Recorder::rewind() {
    
    PrintTr3Recorder("SkyTr3Recorder::rewind\n"); 

    lock.push();
    
    _index = 0;
    _startTime = OSGetTime();
    _deltaTime = 0;
    _startFrame = _frame;
 }

void SkyTr3Recorder::toend() {
    
    PrintTr3Recorder("SkyTr3Recorder::toend\n"); 

    lock.push();
    
    //not implemented
    
    lock.pop();
}

void SkyTr3Recorder::erase() {
    
    PrintTr3Recorder("SkyTr3Recorder::erase\n"); 

    lock.push();
    
    _state = kRecorderErase;
    _tr3TimeFrames.clear();
    
    
    lock.pop();
}

#pragma recoder persist

void SkyTr3Recorder::addPaths() {
    
    for (Tr3TimeFrame* tr3TimeFramei :_tr3TimeFrames) {

        Tr3* tr3 = tr3TimeFramei->_tr3;
        int iden = tr3->par.tr3Id;
        
        if (_tr3Paths.count(iden) == 0) {
                
            string s = tr3->parentPath();
            _tr3Paths[iden]=s;
        }
     }
}

