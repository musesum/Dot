 
#import "main.h"
#import "SoundEffect.h"

#define LogSoundEffect(...) DebugLog(__VA_ARGS__)

@implementation SoundEffect
+ (id)soundEffectWithContentsOfFile:(NSString*)aPath {
    if (aPath) {
        return [SoundEffect.alloc initWithContentsOfFile:aPath];
    }
    return nil;
}

- (id)initWithContentsOfFile:(NSString*)path {
    self = [super init];
    
    if (self != nil) {
        NSURL *aFileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        
        if (aFileURL != nil)  {
            SystemSoundID aSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)aFileURL, &aSoundID); //arc
            
            if (error == kAudioServicesNoError) { // success
                _soundID = aSoundID;
            } else {
                LogSoundEffect(@"Error %d loading sound at path: %@", (int)error, path);
                self = nil;
            }
        } else {
            LogSoundEffect(@"NSURL is nil for path: %@", path);
            self = nil;
        }
    }
    return self;
}

- (void)dealloc {
    AudioServicesDisposeSystemSoundID(_soundID);
}

- (void)play {
    AudioServicesPlaySystemSound(_soundID);
}

@end
