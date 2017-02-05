#import "MenuChild.h"
#import "MuPicker.h"
#import "MenuParent.h"

@class MuPatchPicker;
@class MuPicker;

@interface MenuChildPatch: MenuChild<MenuParentDelegate> {
    MuPatchPicker* _patchPicker;
    MuPicker* _muPicker;
}

@end

