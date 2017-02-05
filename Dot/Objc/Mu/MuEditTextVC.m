
#import "main.h"
#import "MuEditTextVC.h"
#import "TKColorTextStorage.h"

@interface MuEditTextVC ()

@end

@implementation MuEditTextVC


- (id)initWithFrame:(CGRect)frame text:(NSString*)text keys:(NSArray*)keys {
    
    self = [super initWithNibName:nil bundle:nil];

    _textStorage = [TKColorTextStorage.alloc init];
    
    NSLayoutManager* layoutManager = [NSLayoutManager.alloc init];
    
    NSTextContainer* container = [NSTextContainer.alloc initWithSize:CGSizeMake(frame.size.width, CGFLOAT_MAX)];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    [_textStorage addLayoutManager:layoutManager];
    
    UITextView* newTextView = [UITextView.alloc initWithFrame:frame textContainer:container];
    self.view  = newTextView;
    newTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    newTextView.scrollEnabled = YES;
    newTextView.backgroundColor = [UIColor darkGrayColor];
    [newTextView setTextColor:[UIColor whiteColor]];
    
    newTextView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    _textStorage.tokens = [NSMutableDictionary.alloc init];
    [_textStorage.tokens setValue:@{ NSForegroundColorAttributeName : [UIColor whiteColor] } forKey:TKDDefaultTokenName];
    for (NSString* key in keys) {
        [_textStorage.tokens setValue:@{ NSForegroundColorAttributeName : [UIColor redColor  ] } forKey:key];
    }
    NSAttributedString * attributedText = [NSAttributedString.alloc initWithString:text
                                                                          attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
    [_textStorage beginEditing];
    [_textStorage setAttributedString:attributedText];
    [_textStorage endEditing];
    return self;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
