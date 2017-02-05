
#import "MuPicker.h"

@interface MuInfoPicker : UIViewController <UIWebViewDelegate> {
    
    CompletionDict _completion;
    UIWebView*_webView;
    CGRect _scrollFrame;
}

@property(nonatomic,retain) IBOutlet UIWebView* webView;

- (id)initWithCompletion:(CompletionDict)completion_;
@end

