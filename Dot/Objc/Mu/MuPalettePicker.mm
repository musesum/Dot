
#import "MuPalettePicker.h"
#import "UIExtras.h"
#import "SkyTr3.h"
#import "Pals.h"
#import "Rgbs.h"
#import "UIImageRgbs.h"
#import "AppDelegate.h"
#import "OrienteDevice.h"
#import "MuNavigationC.h"

#define LogMuPalettePicker(...) //DebugLog(__VA_ARGS__) 

@implementation MuPalettePicker


- (id)initWithCompletion:(CompletionDict)completion_ {
    
    self = [super init];
    self.view.transform = OrienteDevice.shared.transform;
    _completion = completion_;
    [self initScrollView];
    return self;
}


- (void)initScrollView {
    
    CGRect scrollFrame = CGRectMake(0, 0, 320, 320);
    
    _scrollView = [UIScrollView.alloc initWithFrame:scrollFrame];
    _scrollView.backgroundColor = [UIColor clearColor];

    _thumbs = [NSMutableArray.alloc init];
    int row = 0;
    int column = 0;
    int buttonSize = 64;
    
    CellMain* cellMain = [SkyTr3.shared cellMain];
    Pals* pals = &(cellMain->pic.pix.pals); 
    
    int columns = scrollFrame.size.width/buttonSize;
    for (int i=0; i<PresetMax; i++) {
        
        if (pals->preset[i]==0)
            break; // nil terminated list
        
        UIImage* thumb =  [UIImageRgbs imageFromRgbs:&(pals->preset[i]->rgbs) size:CGSizeMake(48, 48)];
        if (!thumb)
            continue;
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(column*buttonSize, row*buttonSize, buttonSize, buttonSize);
        [button setImage:thumb forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i; 
        [_thumbs addObject:button];
        [_scrollView addSubview:button];
        
        column = (column+1)%columns;
        if (column==0)
            row++;
    }
    CGSize scrollSize = CGSizeMake( scrollFrame.size.width, row* buttonSize);
    [_scrollView setContentSize:scrollSize];
    [self.view addSubview:_scrollView];
}

- (void)buttonClicked:(id)sender {
    
    UIButton* button = (UIButton*)sender;
    NSNumber* palTag = [NSNumber numberWithInt:button.tag];

    if (_completion) {
        _completion(@{@"result":@"done", @"palTag":palTag});
    }
}

@end

