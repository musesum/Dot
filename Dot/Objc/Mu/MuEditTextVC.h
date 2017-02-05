
@class TKColorTextStorage;

@interface MuEditTextVC : UIViewController {
    
    TKColorTextStorage* _textStorage;
}

- (id)initWithFrame:(CGRect)frame text:(NSString*)text keys:(NSArray*)keys;

@end
