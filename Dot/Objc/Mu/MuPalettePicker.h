
#import "MuPicker.h"
#import "Completion.h"

@interface MuPalettePicker : UIViewController {

	NSMutableArray* _thumbs;
    UIScrollView*   _scrollView;
    CompletionDict _completion;
};

- (id)initWithCompletion:(CompletionDict)completion_;


- (void)buttonClicked:(id)sender;

@end

