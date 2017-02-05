
#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>

typedef enum {
    
    kSysSoundXylo,
    kSysSoundErase,
    kSysSoundSelect,
    kSysSoundMax
} SysSound;

@interface SysSoundController : NSObject {

	CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject;

}

@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;

+ (id)shared;
- (void)playSound;
@end

