#ifndef OscArg_H
#define OscArg_H

#include <string>
#include "OscArgType.h"

struct OscArg {
    
    OscArg(OscArg&arg)     {
        
        _oscArgType = arg._oscArgType;
        
        switch (_oscArgType) {
        
            case kOscArgType_Int32   : _ivalue = arg._ivalue; break;
            case kOscArgType_Float   : _fvalue = arg._fvalue; break;
            case kOscArgType_String  : _svalue = new std::string(arg._svalue->c_str()); break;
            default: break;
        }
    }
    OscArg(){_oscArgType = kOscArgType_Undfined;}
	OscArg(float value)      { set(value); }
	OscArg(int32_t value)    { set(value); }
	OscArg(const char*value) { set(value); }
	OscArg(std::string value){ set(value.c_str()); }    
    
    ~OscArg() {if (_oscArgType==kOscArgType_String) delete _svalue;}

    void set(float   value )   {_oscArgType = kOscArgType_Float;  _fvalue = value; }
    void set(int32_t value )   {_oscArgType = kOscArgType_Int32;  _ivalue = value; }
    void set(const char*value) {_oscArgType = kOscArgType_String; _svalue = new std::string(value); }

    operator float()        const {return _fvalue;}
    operator std::string()  const {return*_svalue;}
    operator int32_t()      const {return _ivalue;}
    
    OscArgType getType() { return _oscArgType; }
    
    std::string getTypeName() {
        
        switch (_oscArgType) {
        
            case kOscArgType_Int32   : return "int";
            case kOscArgType_Float   : return "float";
            case kOscArgType_String  : return "string";
                /*
            case kOscArgType_True    : return "true";
            case kOscArgType_False   : return "false";
            case kOscArgType_None    : return "none";                
            case kOscArgType_Blob    : return "blob";  
                 */
            default              : return "undefined";
        }
    }
    
    OscArgType _oscArgType;
    
    union {	
        int32_t      _ivalue;
        float        _fvalue;
        std::string *_svalue;
    };
};

#endif