
#import "MuPicker.h"

typedef enum {
    
    kInfoLockOff,
    kInfoLockEverything, // child lock
    
}   InfoLockStatus;


typedef enum {
    
    kInfoAlertOff,
    kInfoAlertReplies,
    kInfoAlertFriends,
    kInfoAlertMuse,
}   InfoAlertStatus;

#define kInfoLockStatusKey @"InfoLockStatus"


@interface InfoView : UIScrollView  <UIScrollViewDelegate>  {
    
    CGSize _size;
}
@property(nonatomic,weak) id muPickerDelgate;
@property(nonatomic,strong) NSMutableArray* titles;


- (id)initWithDelegate:(id)delegate_ size:(CGSize)size_;
- (void)goNext;

@end
