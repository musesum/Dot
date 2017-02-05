/*
 *  Tr3Message.h
 *  PearlTr3Sky20
 *
 *  Created by Warren Stringer on 6/12/10.
 *  Copyright 2010 Muse.com, Inc. All rights reserved.
 *
 */

#import "string.h"
#import "stdlib.h"
#import "DoubleBufferThread.h"
#import "Tr3.h"

typedef enum {
    
    kTypeFloat,
    kTypeInt,
    kTypeStr,
} MessageType;


struct Tr3Message {

    Tr3Message(Tr3*tr3_, float value_) { 
        
        _tr3 = tr3_;
        _messageType = kTypeFloat;
        _fvalue = value_;
    }
    
    Tr3Message(Tr3*tr3_, int value_) { 
        
        _tr3 = tr3_;
        _messageType = kTypeInt;
        _ivalue = value_;
    }
    
    Tr3Message(Tr3*tr3_, char * value_) { 
        
        _tr3 = tr3_;
        _messageType = kTypeStr;
        char *str = (char*)malloc(strlen(value_)+1); 
        strcpy(str, value_);
        _svalue = str;
    }
    ~Tr3Message() {
        
        if (_messageType == kTypeStr)
            free(_svalue);
    }
    
    void goMessage() {
        
        switch (_messageType) {
            case kTypeFloat: _tr3->setNow(_fvalue); break;
            case kTypeInt:   _tr3->setNow(_ivalue); break;
            case kTypeStr:   _tr3->setNow(_svalue); break;
        }
    }
    
    Tr3* _tr3;
    MessageType _messageType;
    union {
        
        int     _ivalue;
        float   _fvalue;
        char    *_svalue;
    };
};

struct Tr3Messages  {
    
    void addMessage(Tr3*tr3_, float value_) { _tr3Messages.push(new Tr3Message(tr3_,value_));}
    void addMessage(Tr3*tr3_, int   value_) { _tr3Messages.push(new Tr3Message(tr3_,value_));}
    void addMessage(Tr3*tr3_, char* value_) { _tr3Messages.push(new Tr3Message(tr3_,value_));}
    
    static DoubleBufferThread<Tr3Message> _tr3Messages;
    
    Tr3Messages() {
        pthread_create(&_tr3Messages._thread, NULL, &Tr3Messages::runLoop, 0);
    }
    static void *runLoop(void *ignore) {
        
        for (;;) {
            
            Tr3Message* msg;
            
            while ((msg = _tr3Messages.pop()) > 0) {
                
                msg->goMessage();
                delete msg;
            }
            _tr3Messages.flipMessageDoubleBuffer();
        }
        return NULL;
    }
    
};
