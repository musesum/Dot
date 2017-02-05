#import "MenuChild.h"
#import "MuPicker.h"

@class MuImagePicker;
@class SkyPatch;

@interface MenuChildCamera: MenuChild {
    
    NSTimer* _imagePickerReleaseTimer;

}

@property(strong) MuImagePicker*imagePicker;
@property bool doubleTapping; 

- (id)initWithPatch:(SkyPatch*)patch_;
@end

