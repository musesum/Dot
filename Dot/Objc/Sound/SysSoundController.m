

#import "SysSoundController.h"

@implementation SysSoundController

@synthesize soundFileURLRef;
@synthesize soundFileObject;

+ (id)shared {
    
    static SysSoundController *sysSoundController = 0;
    if (!sysSoundController) {
        sysSoundController = [SysSoundController.alloc init];
    }
    return sysSoundController;
}

- (id)init {

    self = [super init];
    
    NSURL *url   = [[NSBundle mainBundle] URLForResource: @"Select" withExtension: @"caf"];
    self.soundFileURLRef = (CFURLRef) CFBridgingRetain(url);
    AudioServicesCreateSystemSoundID ( soundFileURLRef, &soundFileObject);
    return self;
}


- (void)playSound {

    AudioServicesPlaySystemSound (soundFileObject);
}


- (void)dealloc {

    AudioServicesDisposeSystemSoundID (soundFileObject);
    CFRelease (soundFileURLRef);
}

@end
