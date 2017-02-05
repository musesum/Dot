#import "CellRuleItem.h"


CellRuleItem::CellRuleItem(Tr3*rule_, RuleCall ruleCall_) {
    
    rule     = rule_;
    ruleOn   = rule->bind("on");
    canvas0  = rule->bind("canvas0");
    canvas1  = rule->bind("canvas1");
    version  = rule->bind("version");
    runOnce  = rule->bind("runOnce");
    mix2univ = rule->bind("mix2univ");
    ruleCall = ruleCall_;
    
    mix.bindTr3(rule);
}

