
#include <AudioToolbox/AudioToolbox.h>

@interface AlertSound : NSObject {
    
	CFURLRef		_soundFileURLRef;
	SystemSoundID	_soundFileObject;
    bool            _on;
}
@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;
@property (nonatomic,getter=isOn)	bool on;

+ (AlertSound*)shared;

- (void)play;       // play but do not overlap
- (void)playAlways; // play regardless of overlap

@end
