#import "BrowserVC.h"
#import "BonjourPicker.h"
#import "TCPServer.h"
#import "AppSessionState.h"
#import "Tr3.h"

@interface AppNetworkView : UIView <UIApplicationDelegate, UIActionSheetDelegate,
									 BrowserVCDelegate, TCPServerDelegate>
{
	TCPServer		*_server;
	NSInputStream	*_inStream;
	NSOutputStream	*_outStream;
	BOOL			_inReady;
	BOOL			_outReady;
    UIView          *_window;   
    AppSessionState _appSessionState;
    
    NSMutableDictionary *_tr3Id; // translate incoming id to local Tr3* 
    
    Tr3* root;
    Tr3* _publish;
    Tr3* _subscribe;
}
@property(nonatomic,readonly) BonjourPicker*picker;
@property(nonatomic,strong) NSString*name;


void Tr3Publish(Tr3*tr3,Tr3CallData*data);
- (void)tr3Publish:(Tr3*)tr3;

void Tr3Subscribe(Tr3*tr3,Tr3CallData*data);
- (void)tr3Subscribe:(Tr3*)tr3;

- (bool)send:(const char*)message;

- (void)tr3PublishHandshake;
- (void)tr3SubscribeHandshake;

- (void)setup:(UIView*)window_;
@end
