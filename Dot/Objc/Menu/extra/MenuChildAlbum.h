#import "MenuChild.h"
#import "MuPicker.h"
@class MuImagePicker;

@interface MenuChildAlbum: MenuChild {
    
    NSTimer* _imagePickerReleaseTimer;

}
@property (strong) MuImagePicker* imagePicker;
@property bool doubleTapping; 

- (id)initWithPatch:(SkyPatch*)patch;

@end

