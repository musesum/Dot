
#import "AlertSound.h"

@implementation AlertSound

@synthesize soundFileURLRef = _soundFileURLRef;
@synthesize soundFileObject = _soundFileObject;
@synthesize on = _on;

static bool AlertSoundPlaying;

+ (AlertSound*)shared {
    
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [self.alloc init];
    });
    return shared;
}

void playingCompleted (SystemSoundID  ssID, void* clientData ) {
    
    AudioServicesRemoveSystemSoundCompletion (ssID);
    AlertSoundPlaying = NO;
}

- (id)init {
    
    self = [super init];

	_soundFileURLRef  =	CFBundleCopyResourceURL (CFBundleGetMainBundle (),
                                                 CFSTR ("XyloNoteA3"),
                                                 CFSTR ("caf"),
                                                 NULL);
    AudioServicesCreateSystemSoundID (_soundFileURLRef, &_soundFileObject);
    AlertSoundPlaying = NO;
    _on = YES;
 	return self;
}

- (void) play {
    
    if (_on && !AlertSoundPlaying) 
    {
        AudioServicesAddSystemSoundCompletion( _soundFileObject, nil, nil, playingCompleted, (__bridge void* )(self));
        AudioServicesPlayAlertSound (self.soundFileObject);
        AlertSoundPlaying = YES;
    }
}
- (void) playAlways {
        AudioServicesPlayAlertSound (self.soundFileObject);
}
    
@end
