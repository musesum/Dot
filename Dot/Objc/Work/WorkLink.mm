#import "WorkLink.h"
#import "MenuDock.h"
#import "Tr3Cache.h"
#import "Tr3Osc.h"
#import "VideoManager.h"
#import "SkyTr3Root.h"

@implementation WorkLink

+ (WorkLink*)shared {
    static WorkLink*workLink = 0;
    if (!workLink) {
        workLink = [WorkLink.alloc init];
    }
    return workLink;
}

- (id) init {
    
    self = [super init];
    
    _videoManager  = [VideoManager shared];
    _delegates     = [NSMutableArray.alloc init];
    
    displayLink = [UIScreen.mainScreen displayLinkWithTarget:self selector:@selector(drawFrame)];
    [displayLink setFrameInterval:1];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    self = [super init];
    _active = YES;
    Tr3*sky =  SkyRoot->bind("sky");
    _tr3MainFrame = sky->bind("main.frame");
    _tr3Osc = new Tr3Osc(sky); //TODO:need to test whether can bind, otherwise will crash by throwing user runtime error "unable to bind udp socket"
    
    return self;
}

- (void)drawFrame {
    
    Tr3Cache::flush();
    
    if (_videoManager.captureFlags == AVCaptureDevicePositionBack ||
        _videoManager.captureFlags == AVCaptureDevicePositionFront) {
        
        ;
    }
    else {
        for (id<WorkLinkDelegate>delegate in _delegates) {
            [delegate NextFrame];
        }
    }
    [self goApp];

}

- (void)goApp {
    
    static bool block = NO;
    if (block)
        return;
    block = YES;
    
    if (_tr3Osc) {
        _tr3Osc->OscReceiverLoop();
    }
    static int count=0;
    _tr3MainFrame->setNow(count++);
    block  = NO;
}

@end
