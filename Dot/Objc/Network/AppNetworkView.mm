

#import "AppNetworkView.h"
#import "BonjourPicker.h"
#import "CallIdSel.h"
#import <unordered_map>
#import "SkyTr3Root.h"
#define kNumPads 3
#define LogAppNetworkView(...) DebugLog(__VA_ARGS__)

// The Bonjour application protocol, which must:
// 1) be no longer than 14 characters
// 2) contain only lower-case letters, digits, and hyphens
// 3) begin and end with lower-case letter or digit
// It should also be descriptive and human-readable
// See the following for more information:
// http://developer.apple.com/networking/bonjour/faq.html
#define kGameIdentifier		@"MusePearlTr3Sky"

std::unordered_map<int, Tr3*> IdTr3;

@interface AppNetworkView ()
- (void) setup;
- (void) presentPicker:(NSString*)name;
@end

#pragma mark -

@implementation AppNetworkView


- (void) showErrorAlert:(NSString*)title {
    
	UIAlertView* alertView = [UIAlertView.alloc initWithTitle:title message:@"Check your networking configuration." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
}
- (void) showStatusAlert:(NSString*)title {
    UIAlertView* alertView = [UIAlertView.alloc initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
    [alertView show];
}
- (void) dealloc {	
    
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) setup {
    
	_server = nil;
	
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	_inStream = nil;
	_inReady = NO;
    
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	_outStream = nil;
	_outReady = NO;
	
	_server = [TCPServer new];
	[_server setDelegate:self];
	NSError* error;
	if(_server == nil || ![_server start:&error]) {
		LogAppNetworkView(@"Failed creating server: %@", error);
		[self showErrorAlert:@"Failed creating server"];
		return;
	}
	
	//Start advertising to clients, passing nil for the name to tell Bonjour to pick use default name
	if(![_server enableBonjourWithDomain:@"local" applicationProtocol:[TCPServer bonjourTypeFromIdentifier:kGameIdentifier] name:nil]) {
		[self showErrorAlert:@"Failed advertising server"];
		return;
	}
    
	[self presentPicker:nil];
}
- (void) setup:(UIView*)window_ {
    
    _window = window_;
    Tr3* dot = root->bind("main.dot");

    _publish   = dot->bind("Publish"  ,(Tr3CallTo)(&Tr3Publish),  (void*)new CallIdSel(self));
    _subscribe = dot->bind("Subscribe",(Tr3CallTo)(&Tr3Subscribe),(void*)new CallIdSel(self));
    _tr3Id = [NSMutableDictionary.alloc init];
    
    [self setup];
}

void Tr3Publish(Tr3*tr3,Tr3CallData*data) {
    
    id target = (__bridge id)(data->_instance);
    [target tr3Publish:tr3];
}

- (void)tr3Publish:(Tr3*)tr3 {
    
    if (_appSessionState!= kAppSessionPublisher)
        return;
    
    LogAppNetworkView(@"%s from:%s",sel_getName(_cmd),tr3->parentPath());
    
    char* message[256]; //TODO message length
    sprintf((char*)message, "tr3msg %i %f ", tr3->par.tr3Id,(float)*tr3);
    [self send:(const char*)message];
}

void Tr3Subscribe(Tr3*tr3,Tr3CallData*data) {
    
    id target = (__bridge id)(data->_instance);
    [target tr3Subscribe:tr3];
}
- (void)tr3Subscribe:(Tr3*)tr3 {

    LogAppNetworkView(@"%s from:%s",sel_getName(_cmd),tr3->parentPath());
}

- (void)tr3PublishHandshake {
    
    char message[512]; //TODO: message length
    
    for (Tr3Edge* edge : _publish->edgeGroup.edges) {
        
        if (edge->flags.find) {
            
            Tr3*tr3 = edge->rght;
            sprintf(message,"tr3id %s %i",tr3->parentPath(), tr3->par.tr3Id);
            
            if (![self send:(const char*)message]) {
                
                [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(tr3PublishHandshake) userInfo:nil repeats:NO];
                LogAppNetworkView(@"timeout for %s",message);
                return;
            }
            LogAppNetworkView(@"out %s",message);
        }
    }
}
- (void)tr3SubscribeHandshake {
}

// Make sure to let the user know what name is being used for Bonjour advertisement.
// This way, other players can browse for and connect to this game.
// Note that this may be called while the alert is already being displayed, as
// Bonjour may detect a name conflict and rename dynamically.
- (void) presentPicker:(NSString*)name {
    
	if (!_picker) {
		_picker = [BonjourPicker.alloc initWithFrame:[[UIScreen mainScreen] applicationFrame] type:[TCPServer bonjourTypeFromIdentifier:kGameIdentifier]];
		_picker.bvc.delegate = self;
	}
	
	_picker.gameName = name;
    
	if (!_picker.superview) {
		[_window addSubview:_picker];
	}
}

- (void) destroyPicker {
    
	[_picker removeFromSuperview];
	_picker = nil;
}

// If we display an error or an alert that the remote disconnected, handle dismissal and return to setup
- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
	[self setup];
}
- (bool) send:(const char*)message {
    
    int len = strlen(message);
	if (_outStream && [_outStream hasSpaceAvailable]) {
        int outLen = [_outStream write:(const uint8_t*)message maxLength:len+1];
		if (outLen == -1) {
			[self showErrorAlert:@"Failed sending data to peer"];
        }
        else {
            return true;
        }
    }
    return false;
}
- (void) openStreams {
    
	_inStream.delegate = (id <NSStreamDelegate>)self;
	[_inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream open];
	_outStream.delegate = (id <NSStreamDelegate>)self;
	[_outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream open];
}
- (void) browserVC:(BrowserVC*)bvc didResolveInstance:(NSNetService*)netService
{
	if (!netService) {
		[self setup];
		return;
	}
    
	// note the following method returns _inStream and _outStream with a retain count that the caller must eventually release
	if (![netService getInputStream:&_inStream outputStream:&_outStream]) {
		[self showErrorAlert:@"Failed connecting to server"];
		return;
	}
    _appSessionState = kAppSessionSubscriber;
	[self openStreams];
}
@end
#pragma mark -
@implementation AppNetworkView (NSStreamDelegate)

- (void) receiveData:(const char*)buffer  {
    
    NSString* message = [NSString stringWithUTF8String:buffer];
    LogAppNetworkView(@"in %@",message);
	NSArray* parts = [message componentsSeparatedByString:@" "];
	NSString* verb = [parts objectAtIndex:0];
    
    if ([verb isEqualToString:@"tr3id"]) {
        
        NSString* path  = [parts objectAtIndex:1];
        int tr3i = [[parts objectAtIndex:2] intValue];
        const char* tr3path = [path UTF8String];

        Tr3*tr3 = SkyRoot->bind(tr3path);
        
        if (tr3 && tr3->par.tr3Id > 0) {
            
            IdTr3[tr3i]= tr3;
        }
        else {
            NSString* message2 = [NSString stringWithFormat:@"tr3not %@ %i", path, tr3i];
            //[self performSelectorOnMainThread:@selector(send:) withObject:message waitUntilDone:NO];
            [self send:[message2 UTF8String]];
        }
    }  
    else if ([verb isEqualToString:@"tr3not"]) {
        
        NSString* path  = [parts objectAtIndex:1];
        NSString* tr3i = [parts objectAtIndex:2];
        
        LogAppNetworkView(@"path:%@ id:%@ not found", path,tr3i);
    }
    else if ([verb isEqualToString:@"tr3msg"]) {
        
        int tr3i = [[parts objectAtIndex:1] intValue];
        float what  = [[parts objectAtIndex:2] floatValue];
        Tr3*tr3 = IdTr3[tr3i];
        if (tr3) {
            tr3->setNow(what);
        }
    }
}
- (void) stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode {
    
    LogAppNetworkView(@"%s",sel_getName(_cmd));
    
    switch(eventCode) {
            
		case NSStreamEventOpenCompleted:
		{
			[self destroyPicker];
			
			_server = nil;
            
			if (stream == _inStream)
				_inReady = YES;
			else
				_outReady = YES;
			
			if (_inReady && _outReady) {
                [self showStatusAlert:@"Connected"];
			}
			break;
		}
		case NSStreamEventHasBytesAvailable:
		{
			if (stream == _inStream) {
#define MaxBufSize 255
                unsigned char buffer [MaxBufSize+1] ;
				unsigned int len = 0;
                int i;
                uint8_t*buf = buffer;
                for (i=0; i< MaxBufSize; i++,buf++) {
                    [_inStream read:buf maxLength:1];
                    if (*buf==(uint8_t) 0)
                        break;
                }
                len = i-1;
                NSStreamStatus streamStatus = [stream streamStatus];
				if (len==0) {
                    
					if (streamStatus != NSStreamStatusAtEnd)
						[self showErrorAlert:@"Failed reading data from peer"];
				} 
                else{
                    
                    [self receiveData:(const char*)buffer];
                }
			}
			break;
		}
		case NSStreamEventErrorOccurred:
		{
            NSError* theError = [stream streamError];
            NSString* errorMsg =[NSString stringWithFormat:@"Error %li: %@",
                                 (long)[theError code], [theError localizedDescription]];
            
			LogAppNetworkView(@"%s error:%@",sel_getName(_cmd), errorMsg);
            [self showErrorAlert:errorMsg];			
			break;
		}
			
		case NSStreamEventEndEncountered:
		{			
			LogAppNetworkView(@"%s::NSStreamEventEndEncountered", sel_getName(_cmd));
            UIAlertView* alertView = [UIAlertView.alloc initWithTitle:@"Disconnected!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
			[alertView show];
            break;
		}
	}
}

@end


#pragma mark -
@implementation AppNetworkView (TCPServerDelegate)

- (void) serverDidEnableBonjour:(TCPServer*)server withName:(NSString*)string
{
	LogAppNetworkView(@"%s",sel_getName(_cmd));
    self.name = string;
	[self presentPicker:string];
}

- (void)didAcceptConnectionForServer:(TCPServer*)server inputStream:(NSInputStream*)istr outputStream:(NSOutputStream*)ostr
{
	LogAppNetworkView(@"%s", sel_getName(_cmd));
    if (_inStream || _outStream || server != _server) 
		return;
    
	_appSessionState = kAppSessionPublisher;
    
	_server = nil;
	
	_inStream = istr;
	_outStream = ostr;
	
	[self openStreams];
    [self tr3PublishHandshake];
}

@end
