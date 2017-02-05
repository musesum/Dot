#import "Tr3.h"
#import "../main/SkyDefs.h"
#import "../pixel/MixSet.h"

struct Univ;
struct Mix;
struct FaceMap;
struct Pic;

struct CellRules;
struct CellRuleItem;
typedef void (CellRules::*RuleCall)();
typedef unordered_map<string,CellRuleItem*>NameRules;
typedef unordered_map<string,RuleCall>NameCalls;

struct CellRules {
    
    Tr3* cellNow; // name of rule to find in rule[nameNow]
    Tr3* cellGo;
    Tr3* cellRules;
 
    CellRuleItem* ruleNow;
    CellRuleItem* rulePrev; // old rule to push pop

    NameRules nameRules;
    NameCalls nameCalls;
    
    Univ* univ;
    Mix* mix;
    FaceMap* faceMap;
    
    bool pushed;
    int x,y;
    int* prev;  // itereated prev -- temp during rule evaluation
    int* next;	// itereated next -- temp during rule evaluation
    byte* buf;	// itereated buf  -- temp during rule evaluation
    
    CellRules(){}
    void init(Tr3*, Pic*);
    bool addRule(Tr3* tr3);
    bool addRuleCall(Tr3*tr3,RuleCall call);
    
    void changeRule(Tr3*tr3, void*data);
    static void call_changeRule(Tr3*tr3,void*data) {
        Tr3CallData* callData = (Tr3CallData*)data;
        ((CellRules*)(callData->_instance))->changeRule(tr3,data);
    }
    
    //Tr3CallbackEvent(CellRules, bangRule);
    void bangRule(Tr3*tr3, void*data);
    static void call_bangRule(Tr3*tr3,void*data) {
        Tr3CallData* callData = (Tr3CallData*)data;
        ((CellRules*)(callData->_instance))->bangRule(tr3,data);
    }
    
    void setRule(Tr3*tr3, CellRuleItem*ruleNext);
    CellRuleItem* getRule(string*name);
    
    bool fromMix();
    void go();
    
    void average();
    void laplace();
    void timetun();
    void slide	();
    void drift	();
    void fredkin();
    void modulo	();
    void zha	();
    void fade	();
    void copy   ();
    void fill0	();
    void fill1	();
    void noise	();
    
    void warren	();
    void gas    ();
    void inline swap(Univ*, int,int);
    typedef enum { FromNw=1, FromSw, FromNe, FromSe, FromMax }  FromCell;
    bool inline OctTest(int cell, int shift, FromCell from);
    void inline OctMove(int &r1,int &cell);
    
};
