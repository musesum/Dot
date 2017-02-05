
#import "Tr3Osc.h"
#import "Tr3.h"
#import "Tr3Cache.h"

#define DebugPrintTr3(...) //DebugPrint(__VA_ARGS__)
#define DebugPrintTr3b(...) //DebugPrint(__VA_ARGS__)

Tr3Osc::Tr3Osc (Tr3*root_) {
    
    root = root_;
    
    Tr3* osc = root->bind("osc");
        
    _acc  = osc->bind("accxyz");
    _accX = (*_acc)[0];
    _accY = (*_acc)[1];
    _accZ = (*_acc)[2];
    
    _msaAccel = osc->bind("msaremote.accelerometer");
    _msaXYZ = (Tr3ValTupple*)_msaAccel->val; // TODO: check for 0
    
    _tr3OscOutPort= osc->bind("out.port");
    _tr3OscOutHost= osc->bind("out.host");
    _tr3OscOutMsg = osc->bind("out.message");
    
    _tr3OscInPort = osc->bind("in.port");
    _tr3OscInHost = osc->bind("in.host");
    _tr3OscInMsg  = osc->bind("in.message");
    
    _note         = osc->bind("midi.note");
    _noteNumber   = _note->bind("number");
    _noteVelocity = _note->bind("velocity");
    _noteChannel  = _note->bind("channel");
    _noteDuration = _note->bind("duration");

    Tr3*oscManos  = osc->bind("manos");
    Tr3*tuioPrev = osc->bind("tuio.prev");
    Tr3*tuioNext = osc->bind("tuio.next");
    
    for (int i=0; i < MaxOscTouches; i++) {
        
        char buf[10];
        sprintf(buf, "%i",i);
        _tr3OscManos[i]    = oscManos->bind(buf);
        _tr3OscTuioPrev[i] = tuioPrev->bind(buf);
        _tr3OscTuioNext[i] = tuioNext->bind(buf);

        //_oscPrev[i] = *_tr3OscTuioPrev[i];
        _oscPrevX[i] = (*_tr3OscTuioPrev[i])[0];
        _oscPrevY[i] = (*_tr3OscTuioPrev[i])[1];
        _oscPrevZ[i] = (*_tr3OscTuioPrev[i])[2];
        _oscPrevF[i] = (*_tr3OscTuioPrev[i])[3];
        
        //_oscNext[i] = *_tr3OscTuioPrev[i];
        _oscNextX[i] = (*_tr3OscTuioPrev[i])[0];
        _oscNextY[i] = (*_tr3OscTuioPrev[i])[1];
        _oscNextZ[i] = (*_tr3OscTuioPrev[i])[2];
        _oscNextF[i] = (*_tr3OscTuioPrev[i])[3];
    }

    for (int j=0; j<MaxOscTouches; j++) {
     
        _oscTouchMap [j]=-1;
        _oscTouchPrev[j]=-1;
    }
    _receiver.setup(*_tr3OscInPort);
}

void Tr3Osc::OscTuioAlive(OscMessage *msg) {
    
    // save previousa and mark new for compare and cleanup
    
    for (int j=0; j<MaxOscTouches; j++) {
        
        _oscTouchPrev[j] = _oscTouchMap[j];
        _oscTouchMap[j]  = _oscTouchMap[j]; 
    }
    
    // find existing and flip negative to positive
    
    int size =  msg->_oscArgs.size();    

    for (int i=1; i < size; i++) {
        
        int ivalue =  msg->getArg(i)._ivalue; 
        
        for (int j=0; j<MaxOscTouches; j++) {
            
            if (_oscTouchMap[j]==ivalue) {
                
                _oscTouchMap[j] += MaxOscTouches; // this one's found, so reuse
                break; // onto next alive item
            }
        }
    }
    
    //mark unclaimed as available, with 0
    
    for (int j=0; j<MaxOscTouches; j++) {
        
        if (_oscTouchMap[j] < MaxOscTouches) {
            
            _oscTouchMap[j] = -1; //
        }
        else {
            _oscTouchMap[j] -= MaxOscTouches;
        }
    }
    // now free slots have a value of -1 
    // assign new ones to reclaimed
    
    for (int i=1; i < size; i++) {
        
        int ivalue =  msg->getArg(i)._ivalue; 
        bool valueReused = false;
        
        for (int j=0; j<MaxOscTouches; j++) {
            
            if (_oscTouchMap[j]== ivalue) {
                
                valueReused = true;
                break; // onto next alive item
            }
        }
        if (!valueReused) {
            
            for (int j=0; j<MaxOscTouches; j++) {
            
                if (_oscTouchMap[j]==-1) {
                
                    _oscTouchPrev[j] = -1;      // signal starting point of line is 
                    _oscTouchMap[j] = ivalue; // same as end point for new touch
                    
                    break; // onto next alive item
                }
            }
        }
    }
    for (int j=0; j<MaxOscTouches; j++) {
        
        DebugPrintTr3(" %2.i",_oscTouchMap[j]); 
    }
}


void Tr3Osc::OscTuioSet(OscMessage *msg, OscProfileType type) {
    
    int ivalue =  msg->getArg(1)._ivalue;
    
    for (unsigned int j=0; j < MaxOscTouches; j++) {
        
        if (_oscTouchMap[j]==ivalue) {
                        
            float x = msg->getArg(2)._fvalue;
            float y = msg->getArg(3)._fvalue;
                        
            if(_oscTouchPrev[j]>-1) {
                
                *_oscPrevX[j] = *_oscNextX[j]; // x
                *_oscPrevY[j] = *_oscNextY[j]; // y;
            }
            else {
                *_oscPrevX[j] = x;
                *_oscPrevY[j] = y;
            }

            *_oscNextX[j] = x;
            *_oscNextY[j] = y;
            
            if (type == kOscProfile25Dblb) {
            
                float z =  msg->getArg(4)._fvalue;
                float f =  msg->getArg(8)._fvalue;
                *_oscNextZ[j] = z;
                *_oscNextF[j] = f;
                
                DebugPrintTr3("\n(%i:%i -> x:%.2f y:%.2f z:%.2f f:%.2f) ",j,_oscTouchMap[j],x,y,z,f);
            }
            else {
                DebugPrintTr3("\n(%i:%i -> x:%.2f y:%.2f) ",j,_oscTouchMap[j],x,y);
            }
            _tr3OscTuioNext[j]->bang();
            
            break;
        }
    }
}

void Tr3Osc::OscReceiverLog(OscMessage *msg) {
    
    string status;
    status = msg->_address + " ";
    
    int size =  msg->_oscArgs.size();
    for ( int i=0; i<size; i++ ) {
        
        OscArg&arg =  msg->getArg(i);
        
        //status += " " + arg.getTypeName() + ":";
        
        const char *buf= (const char*)malloc(128);
        
        switch (arg._oscArgType) {
                
            case kOscArgType_Int32:  { sprintf((char*)buf,"%i",arg._ivalue);            status += buf; break; }
            case kOscArgType_Float:  { sprintf((char*)buf,"%.2f",arg._fvalue);          status += buf; break; }
            case kOscArgType_String: { sprintf((char*)buf,"%s",arg._svalue->c_str());   status += buf; break; }
            default: break;
        }
        status += " ";
    }
    DebugPrintTr3("\n%s",status.c_str());    
}

void Tr3Osc::OscTuio(OscMessage *msg, OscProfileType type) {
    
    string *opcode = msg->getArg(0)._svalue;
    
    if      (*opcode == "alive") { OscTuioAlive(msg);}
    else if (*opcode == "set")   { OscTuioSet(msg,type);}    
}

void Tr3Osc::OscLogMessage(OscMessage *msg) {
    
    static char buf[120];
    string message = msg->_address;
    message.append("\n");
    
    for (unsigned int i=0; i< msg->_oscArgs.size(); i++ ) {
        
        //TODO: check for malformed messages
        OscArg&arg =  msg->getArg(i);
        
        switch (arg._oscArgType) {
                
            case kOscArgType_Int32:  { sprintf((char*)buf," %i",arg._ivalue);           break; }
            case kOscArgType_Float:  { sprintf((char*)buf," %.2f",arg._fvalue);         break; }
            case kOscArgType_String: { sprintf((char*)buf," %s",arg._svalue->c_str());  break; }
            default: continue;
        }
        message.append(buf);
    }
    char *messageTr3 = (char*) message.c_str();
    Tr3Cache::set(_tr3OscInMsg,messageTr3);
}


void Tr3Osc::OscTr3(OscMessage *msg) {
    
    int paramBegin =  msg->_address.find('(');

    string tr3Address =  msg->_address.substr(5, paramBegin-5);

    
    Tr3*tr3 = keyTr3[tr3Address];
    if (!tr3) {
        string tr3Path = tr3Address;
        for (int i=0; i < tr3Path.length(); i++) {
 
            if (tr3Path.at(i)=='/') {
                tr3Path.at(i)='.';
            }
        }
        tr3 = root->bind(tr3Path.c_str());
        if (tr3 == Tr3::Tr3Nil) {
            DebugPrintTr3("Tr3Osc::OscTr3  %s not found. ",tr3Path.c_str());
            return;
        }
        keyTr3[tr3Address] = tr3;
    }
    DebugPrintTr3b("\n%s",msg->_address.c_str());
    int paramCount = 0;
    if (paramBegin>=0) {
        
        paramBegin++; // get past '(' to beginning of first parameter name

        for (unsigned int i=0; i< msg->_oscArgs.size(); i++ ) {

            int paramEnd=-1;
            for (int j = paramBegin+1; j< msg->_address.size(); j++) {
                
                char c =  msg->_address.at(j);
                if (c==')' || c==',') {
                    paramEnd = j;
                    break;
                }
            }

            string tr3Param =  msg->_address.substr(paramBegin, paramEnd-paramBegin);
            Tr3*tr3Arg = tr3->bind(tr3Param.c_str());
            
            if (tr3Arg!=Tr3::Tr3Nil) {
                
                OscArg&arg =  msg->getArg(i);
                Tr3Cache::setRange01(tr3Arg,arg._fvalue);
                DebugPrintTr3b(" %.2f",arg._fvalue);
            }
            else {
                DebugPrintTr3("Tr3Osc::OscTr3 tr3Param:%s in:%s not found. ",tr3Param.c_str(),  msg->_address.c_str());
            }
            
            // position begin of next param after ','
            paramBegin = paramEnd+1;
            if (paramBegin >=  msg->_address.size())
                break;
        }
    }
    else {
        
        OscArg&arg =  msg->getArg(0);
        Tr3Cache::setRange01(tr3,arg._fvalue);
        DebugPrintTr3b(" %.2f",arg._fvalue);
    }
    OscLogMessage(msg);
}

void Tr3Osc::OscAccxyz(OscMessage *msg) {

    // not really an Osc message but using the same port - put out by the TouchOsc App
        
    float x = msg->getArg(0)._fvalue;
    float y = msg->getArg(1)._fvalue;
    float z = msg->getArg(2)._fvalue;
    
#define kFilteringFactor 0.03
#define kMinEraseInterval 0.5
#define kEraseAccelerationThreshold 2.0

	static float xx; xx = x * kFilteringFactor + xx * (1.0 - kFilteringFactor);
	static float yy; yy = y * kFilteringFactor + yy * (1.0 - kFilteringFactor);
	static float zz; zz = z * kFilteringFactor + zz * (1.0 - kFilteringFactor);
    
    *_accX = -yy;
    *_accY = -xx;
    *_accZ = zz;
    _acc->bang();
    
    DebugPrintTr3("\nTr3Osc::OscAccxyz xx:%.2f,%.2f yy:%.2f,%.2f zz:%.2f,%.2f ",xx,(float)*_accxyzX,yy,(float)*_accxyzY,zz,(float)*_accxyzZ);
    
}
void Tr3Osc::OscMsaAccelerometer(OscMessage *msg) { 

    // not really an Osc message but using the same port - put out by the MSA remote
    
    float x = msg->getArg(0)._fvalue;
    float y = msg->getArg(1)._fvalue;
    float z = msg->getArg(2)._fvalue;
    
    DebugPrintTr3("\nTr3Osc::OscMsaAccelerometer x:%.2f y:%.2f z:%.2f ",x,y,z);
    static Floats xyz;
    static bool firstTime = true;
    if (firstTime) {
        firstTime = false;
        xyz.push_back(0);
        xyz.push_back(0);
        xyz.push_back(0);
    }
    static float xx; xx = x * kFilteringFactor + xx * (1.0 - kFilteringFactor);
	static float yy; yy = y * kFilteringFactor + yy * (1.0 - kFilteringFactor);
	static float zz; zz = z * kFilteringFactor + zz * (1.0 - kFilteringFactor);
    
    ((Tr3ValScalar*)(*_msaXYZ)[0])->setFloat(-yy); // _msaAccel->rangeTo01(-yy);
    ((Tr3ValScalar*)(*_msaXYZ)[1])->setFloat(-xx); // _msaAccel->rangeTo01(-xx);
    ((Tr3ValScalar*)(*_msaXYZ)[2])->setFloat(zz); // _msaAccel->rangeTo01(zz);
    _msaAccel->bang();
}
void Tr3Osc::OscMidiNote(OscMessage *msg) { 

    // not really an Osc message but using the same port - put out by the TouchOsc App
        
    int number      = msg->getArg(0)._ivalue;
    int velocity    = msg->getArg(1)._ivalue;
    int channel     = msg->getArg(2)._ivalue;
    float duration  = 1.;
    
    DebugPrintTr3("\nTr3Osc::OscMidiNote num:%i vel:%i chan:%i ",number,velocity,channel);
    
    _noteNumber->setNow(number);
    _noteVelocity->setNow(velocity);
    _noteChannel->setNow(channel);
    _noteDuration->setNow(duration);
    _note->bang();
}
/* 
 
 * Finger channels:
 contents: string (name), int (hand id), int (finger id), float (x), float (y), float (z)
 
 /finger0-0 _tr3OscManos[0]
 /finger0-1 _tr3OscManos[1]
 /finger0-2 _tr3OscManos[2]
 /finger0-3 _tr3OscManos[3]
 /finger0-4 _tr3OscManos[4]
 /finger1-0 _tr3OscManos[5]
 /finger1-1 _tr3OscManos[6]
 /finger1-2 _tr3OscManos[7]
 /finger1-3 _tr3OscManos[8]
 /finger1-4 _tr3OscManos[9]
 
*/
void Tr3Osc::OscManosFinger(OscMessage *msg) {
    
    int hand    = msg->getArg(1)._ivalue;
    int finger  = msg->getArg(2)._ivalue;
    float x     = msg->getArg(3)._fvalue;
    float y     = msg->getArg(4)._fvalue;
    float z     = msg->getArg(5)._fvalue;
    
    static float minX = 0; minX = min(minX,x);
    static float minY = 0; minY = min(minY,y);
    static float minZ = 0; minZ = min(minZ,z);
    static float maxX = 0; maxX = max(maxX,x);
    static float maxY = 0; maxY = max(maxY,y);
    static float maxZ = 0; maxZ = max(maxZ,z);
    
    float xx = (x-minX)/(maxX-minX);
    float yy = (y-minY)/(maxY-minY);
    float zz = (z-minZ)/(maxZ-minZ);
 
    int index = max(0,min(9,hand*5+finger));
    
    Floats* floats = new Floats;
    floats->push_back(xx);
    floats->push_back(yy);
    floats->push_back(zz);
    Tr3Cache::setRange01(_tr3OscManos[index],floats);


    DebugPrintTr3("\nTr3Osc::OscManosFinger:%i x(%.2f : %.2f) y(%.2f : %.2f) z(%.2f : %.2f)",finger,minX,maxX,minY,maxY,minZ,maxZ);
}

int Tr3Osc::OscReceiverLoop(){
    
    OscReceiver::_oscMessages.flipMessageDoubleBuffer();
    OscMessage *msg;

    try {
        
        while ((msg = _receiver.getNextMessage()) != NULL) {
            
            int length = msg->_address.size();
            if (length<3 || length >120) {
                Debug(fprintf(stderr,"**** Tr3Osc unexpected msg");)
                continue;
            }
            
            if      (length >= 10 && msg->_address.substr(0,10)=="/midi/note")   { OscMidiNote(msg);}
            else if (length >= 11 && msg->_address.substr(0,11)=="/tuio/2Dobj")  { OscTuio(msg,kOscProfile2Dobj);}
            else if (length >= 11 && msg->_address.substr(0,11)=="/tuio/2Dcur")  { OscTuio(msg,kOscProfile2Dcur);}
            else if (length >= 11 && msg->_address.substr(0,11)=="/tuio/2Dblb")  { OscTuio(msg,kOscProfile2Dblb);}
            else if (length >= 12 && msg->_address.substr(0,12)=="/tuio/25Dblb") { OscTuio(msg,kOscProfile25Dblb);}
            else if (length >=  7 && msg->_address.substr(0,7)=="/accxyz")       { OscAccxyz(msg);}
            else if (length >= 24 && msg->_address.substr(0,24)=="/msaremote/accelerometer"){ OscMsaAccelerometer(msg);}
            else if (length >=  4 && msg->_address.substr(0,4)=="/tr3")          { OscTr3(msg);}
            else if (length >=  7 && msg->_address.substr(0,7)=="/origin")       { OscManosFinger(msg);}
            else if (length >=  7 && msg->_address.substr(0,7)=="/finger")       { OscManosFinger(msg);}
            else if (length >=  7 && msg->_address.substr(0,7)=="/active")       { continue;}
#ifdef DebugOscMessages
            /* both  OscReceiverLog and OscLogMessage crash on malformed messages
             * so only use to debug and the comment out
             */
            else                                                { OscReceiverLog(msg);}
            OscLogMessage(msg); // this is already in OscTr3(msg)
#endif
            delete msg;
            
        }
    } catch (int i) {
        Debug(fprintf(stderr,"**** catch");)
    }
    
    return true;
}
