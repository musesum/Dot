
#import "MuPicker.h"


@interface MuPatchPicker : UIViewController {

    CompletionDict  _completion;
    NSMutableArray* _paths;
	NSMutableArray* _thumbs;
	NSMutableArray* _names;
    CGPoint         _clickedLocation;
}
@property(nonatomic) CGPoint clickedLocation;
@property(nonatomic,strong)UIScrollView* scrollView;

- (id)initWithCompletion:(CompletionDict)completion_;

@end

