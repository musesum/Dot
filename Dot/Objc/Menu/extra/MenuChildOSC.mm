
#import "MenuChildOSC.h"
#import "Tr3.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "CallIdSel.h"
#import "SkyTr3Root.h"
#import "SkyPatch.h"

@implementation MenuChildOSC

- (id)initWithPatch:(SkyPatch*)patch {
    
    CGRect frame = CGRectMake(0,0,320,200);
    self = [super initWithFrame:frame title:@"OSC"];
    [self initFrames:frame];
    [self initTr3Values];
    [self initControls];
    return self;
}

- (void)initTr3Values {
    
     Tr3* osc      = SkyRoot->bind("osc");
    _tr3OscOutPort = osc->bind("out.port");
    _tr3OscOutHost = osc->bind("out.host");
    _tr3OscOutMsg  = osc->bind("out.message");
    
    _tr3OscInPort  = osc->bind("in.port");
    _tr3OscInHost  = osc->bind("in.host");
    _tr3OscInMsg   = osc->Tr3Bind2("in.message",Tr3InMessage);
}

- (void) initFrames:(CGRect)frame_ {
    
    CGFloat w = frame_.size.width;
    CGFloat m = 32; // margin
    _inPortFrame    = CGRectMake(m, 40, w-2*m,24);
    _outPortFrame   = CGRectMake(m, 70, w-2*m,24);
    _myIpFrame      = CGRectMake(m,100, w-2*m,24);
    _inMessageFrame = CGRectMake(m,130, w-2*m,48);
}


- (void)initControls {
    
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    UIColor* background = [UIColor clearColor];
    
//    // in port
//    
//    self.inPort = [UITextField.alloc initWithFrame:_inPortFrame];
//    _inPort.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    _inPort.tag = kInPortTag;
//    _inPort.font = font;
//    _inPort.adjustsFontSizeToFitWidth = YES;
//    _inPort.backgroundColor = [UIColor clearColor];
//    _inPort.textColor = [UIColor whiteColor];
//    _inPort.textAlignment = NSTextAlignmentLeft;
//    _inPort.keyboardType = UIKeyboardTypeDecimalPad;
//    _inPort.clearButtonMode = UITextFieldViewModeWhileEditing;
//    _inPort.autocorrectionType = UITextAutocorrectionTypeNo;
//    _inPort.autocapitalizationType = UITextAutocapitalizationTypeSentences;
//    _inPort.placeholder = [NSString stringWithFormat:@"%i",(int)*_tr3OscInPort ];
//    _inPort.delegate = self;
//    [self addSubview:_inPort];
// 
//    // out port
//    
//    self.inPort = [UITextField.alloc initWithFrame:_outPortFrame];
//    _outPort.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    _outPort.tag = kOutPortTag;
//    _outPort.font = font;
//    _outPort.adjustsFontSizeToFitWidth = YES;
//    _outPort.backgroundColor = [UIColor clearColor];
//    _outPort.textColor = [UIColor whiteColor];
//    _outPort.textAlignment = NSTextAlignmentLeft;
//    _outPort.keyboardType = UIKeyboardTypeDecimalPad;
//    _outPort.clearButtonMode = UITextFieldViewModeWhileEditing;
//    _outPort.autocorrectionType = UITextAutocorrectionTypeNo;
//    _outPort.autocapitalizationType = UITextAutocapitalizationTypeSentences;
//    _outPort.placeholder = [NSString stringWithFormat:@"%i",(int)*_tr3OscOutPort];
//    _outPort.delegate = self;
//    [self addSubview:_inPort];
    
    
    // in port
    
    self.inPort = [UILabel.alloc initWithFrame:_inPortFrame];
    _inPort.enabled         = YES;
    _inPort.text            = [NSString stringWithFormat:@"incoming port: %i",(int)*_tr3OscInPort];
    _inPort.font            = font;
    _inPort.backgroundColor = background;
    _inPort.textColor       = [UIColor whiteColor];
    _inPort.textAlignment   = NSTextAlignmentCenter;
    _inPort.lineBreakMode   = NSLineBreakByClipping;
    _inPort.numberOfLines   = 1;
    [self addSubview:_inPort];
   
    // out port
    
    self.outPort = [UILabel.alloc initWithFrame:_outPortFrame];
    _outPort.enabled         = YES;
    _outPort.text            = [NSString stringWithFormat:@"Outgoing port: %i",(int)*_tr3OscOutPort];
    _outPort.font            = font;
    _outPort.backgroundColor = background;
    _outPort.textColor       = [UIColor whiteColor];
    _outPort.textAlignment   = NSTextAlignmentCenter;
    _outPort.lineBreakMode   = NSLineBreakByClipping;
    _outPort.numberOfLines   = 1;
    [self addSubview:_outPort];

    // my IP
    
    self.myIpAddress = [UILabel.alloc initWithFrame:_myIpFrame];
    _myIpAddress.enabled         = YES;
    _myIpAddress.text            = [NSString stringWithFormat:@"IP Address: %@",[self getIPAddress]];
    _myIpAddress.font            = font;
    _myIpAddress.backgroundColor = background;
    _myIpAddress.textColor       = [UIColor whiteColor];
    _myIpAddress.textAlignment   = NSTextAlignmentCenter;
    _myIpAddress.lineBreakMode   = NSLineBreakByClipping;
    _myIpAddress.numberOfLines   = 1;
    [self addSubview:_myIpAddress];
    
    // in Message
    
    self.inMessage = [UILabel.alloc initWithFrame:_inMessageFrame];
    _inMessage.enabled         = YES;
    _inMessage.text            = @"";
    _inMessage.font            = font;
    _inMessage.backgroundColor = background;
    _inMessage.textColor       = [UIColor whiteColor];
    _inMessage.textAlignment   = NSTextAlignmentCenter;
    _inMessage.adjustsFontSizeToFitWidth = YES;
    _inMessage.numberOfLines   = 0;
    [self addSubview:_inMessage];
}

// Get IP Address
- (NSString *)getIPAddress {
    
    NSString* address = @"error";
    struct ifaddrs* interfaces = NULL;
    struct ifaddrs* temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in*)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}
#pragma mark - tr3 callback

void Tr3InMessage(Tr3*from,Tr3CallData*data) {
    
    id target = (__bridge id)(data->_instance);
    SEL sel = (SEL)(data->_data);
    [target updateInMsg];
}
- (void)updateInMsg {

    _inMessage.text = [NSString stringWithFormat:@"%s",(char*)*_tr3OscInMsg];
}

- (void)onDismissButton {
    
    [self hideWithCompletion:nil];
}

#pragma mark - MenuParentDelegate

- (void)showChild {
    
    _myIpAddress.text = [self getIPAddress];
    [super showChild];
}

- (void)MenuParentSingleTap {

}

- (void)MenuParentDoubleTap {

}


@end
