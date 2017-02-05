
#import "MenuChild.h"
#import "Tr3.h"

typedef enum {
    kInPortTag,
    kOutPortTag,
} OscTag;

struct Tr3;
@class SkyPatch;

@interface MenuChildOSC : MenuChild <UITextFieldDelegate>{
    
    Tr3* _tr3OscInPort;
    Tr3* _tr3OscInHost;
    Tr3* _tr3OscInMsg;
    
    Tr3* _tr3OscOutPort;
    Tr3* _tr3OscOutHost;
    Tr3* _tr3OscOutMsg;

    CGRect _inPortFrame;
    CGRect _outPortFrame;
    CGRect _myIpFrame;
    CGRect _inMessageFrame;
}

- (id)initWithPatch:(SkyPatch*)patch_;

//@property (nonatomic, retain) UITextField* inPort;
//@property (nonatomic, retain) UITextField* outPort;
@property (nonatomic, strong) UILabel* inPort;
@property (nonatomic, strong) UILabel* outPort;
@property (nonatomic, strong) UILabel* myIpAddress;
@property (nonatomic, strong) UILabel* inMessage;

void Tr3InMessage(Tr3*from,Tr3CallData*data);

@end
