#import "Tr3.h"
#import "CellRules.h"

typedef void (CellRules::*RuleCall)();
typedef unordered_map<string,CellRuleItem*>NameRules;
typedef unordered_map<string,RuleCall>NameCalls;

struct CellRuleItem {
    
    Tr3* rule;
    Tr3* ruleOn;
    Tr3* canvas0;
    Tr3* canvas1;
    Tr3* version;
    Tr3* runOnce;
    Tr3* mix2univ; // copy from current mix into uni
    MixSet mix;
    
    RuleCall ruleCall;
    
    CellRuleItem(Tr3* rule_, RuleCall ruleCall_);
};



