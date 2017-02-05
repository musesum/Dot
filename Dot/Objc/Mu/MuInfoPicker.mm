
#import "MuInfoPicker.h"
#import "UIExtras.h"
#import "InfoView.h"
#import "OrienteDevice.h"

#define LogMuInfoPicker(...) //DebugLog(__VA_ARGS__) 

@implementation MuInfoPicker

/* duplicated in InfoView */


- (id)initWithCompletion:(CompletionDict)completion_ {
    
    self = [super init];
     self.view.transform = OrienteDevice.shared.transform;
    _completion = completion_;
    [self initScrollView];
    [self initWebView];
    return self;
}

- (void)initScrollView {
    
    _scrollFrame = CGRectMake(0, 0, 320, 320);;
    _scrollFrame.size.height = _scrollFrame.size.height;
    
    self.webView = [UIWebView.alloc initWithFrame:_scrollFrame];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scrollView.alwaysBounceHorizontal = NO;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_webView];
}

- (void)initWebView {
    
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    NSBundle* bundle = [NSBundle mainBundle];
    NSFileManager* fileManager = [NSFileManager.alloc init];
    NSString* docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    /* get info.HTML from documents or get from bundle and copy to documents
     */
    NSError* error;
    NSStringEncoding encoding;
    
    NSString* infoBuf;
    NSString* infoDocPath = [docDir stringByAppendingPathComponent:@"info.html"];
    
    if ([fileManager fileExistsAtPath:infoDocPath]) {
        
        infoBuf = [NSString.alloc initWithContentsOfFile:infoDocPath usedEncoding:&encoding error:&error];
    }
    else {
        NSString* infoBundlePath = [bundle pathForResource:@"info" ofType:@"html"];
        infoBuf = [NSString.alloc initWithContentsOfFile:infoBundlePath usedEncoding:&encoding error:&error];
        [fileManager copyItemAtPath:infoBundlePath toPath:infoDocPath error:nil];
    }
    
    NSString* resourcePath = [[[[NSBundle mainBundle] resourcePath]
                               stringByReplacingOccurrencesOfString:@"/" withString:@"//"]
                              stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    [_webView loadHTMLString:infoBuf baseURL:[NSURL URLWithString:
                                              [NSString stringWithFormat:@"file:/%@//", resourcePath]]];

}

- (BOOL) webView:(UIWebView*)webView
shouldStartLoadWithRequest:(NSURLRequest*)request
  navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL* url= [request URL];
    NSString* urlString = [url path];
    NSLog(@"\nurlString:%@",url);
    if ([urlString hasSuffix:@".app/"])
        return YES;
    if (url) {
        [[UIApplication sharedApplication] openURL:url];
    }
    return NO;
}


@end

