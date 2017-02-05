
#import "MuPatchPicker.h"
#import "ZipArchive.h"
#import "UIExtras.h"
#import "OrienteDevice.h"
#import "MuNavigationC.h"

#define LogMuPatchPicker(...) DebugLog(__VA_ARGS__)
#define PrintMuPatchPicker(...)  //DebugPrint(__VA_ARGS__)

@implementation MuPatchPicker

- (id)initWithCompletion:(CompletionDict)completion_ {
    self = [super init];
    self.view.transform = OrienteDevice.shared.transform;
    _completion = completion_;
    [self initPathsThumbsNames];
    [self initScrollView];
    [self initButtons];
    return self;
}

- (void) viewWillDisappear:(BOOL)animated {

     if (_completion) {
        _completion(@{@"result":@"done"});
    }
    [super viewWillDisappear:animated];
}


- (void)initScrollView {
    
    CGRect scrollFrame = CGRectMake(0, 0, 320, 320);
    _scrollView = [UIScrollView.alloc initWithFrame:scrollFrame];
    _scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrollView];
}

- (void)initPathsThumbsNames {
    
    _paths  = [NSMutableArray.alloc init];
    _thumbs = [NSMutableArray.alloc init];
    _names  = [NSMutableArray.alloc init];

    NSString* documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSError*  error = nil;
    NSFileManager* fileManager = [NSFileManager.alloc init];
    NSArray* files = [fileManager contentsOfDirectoryAtPath:documentsPath error:&error];
    if (error) {
        NSLog(@"%@",error);
    }

    for (NSString* file in files) {
    
        if ([file hasSuffix:@"Information.muse"] ||
            [file hasSuffix:@"Patch.muse"])  {
            continue;
        }

        NSString* fullPath = [documentsPath stringByAppendingPathComponent:file];
        UIImage* thumb = [self imageFromThumbInZipFile:fullPath];
        if (!thumb)
            continue;
        [_names addObject:[file stringByDeletingPathExtension]];
    }
}
- (void)initButtons {
    
    CGSize buttonSize = CGSizeMake(80, 110); // same as above
    
    for (int i=0; i<[_thumbs count]; i++) {
        
        int row = i/4;
        int col = i%4;
        
        UIImageView* imageView = [UIImageView.alloc initWithFrame:CGRectMake(8, 8, 64, 64)];
        imageView.image = [_thumbs objectAtIndex:i];
        imageView.backgroundColor = [UIColor colorWithWhite:0 alpha:.38];
        imageView.layer.cornerRadius = imageView.frame.size.width/2;
        imageView.layer.masksToBounds = YES;
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(col*buttonSize.width, row*(buttonSize.height), buttonSize.width, buttonSize.height);
        [button addSubview:imageView];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.showsTouchWhenHighlighted = YES;
        button.tag = i;
        
        UILabel*buttonLabel         = [UILabel.alloc init];
        buttonLabel.numberOfLines   = 2;
        buttonLabel.frame           = CGRectMake(0,buttonSize.height-42,buttonSize.width,36);
        buttonLabel.font            = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        buttonLabel.backgroundColor = [UIColor clearColor];
        buttonLabel.textColor       = [UIColor whiteColor];
        buttonLabel.shadowOffset    = CGSizeMake(0, .5);
        buttonLabel.shadowColor     = [UIColor darkGrayColor];
        buttonLabel.textAlignment   = UITextAlignmentCenter;
        buttonLabel.lineBreakMode   = UILineBreakModeWordWrap;
        buttonLabel.text            = [_names objectAtIndex:i];
        
        [button addSubview:buttonLabel];
        
        [_scrollView addSubview:button];
    }
    int fileCount = [_thumbs count];
    int cols = 4;
    int rows = 1+(fileCount-1)/cols;
    
    CGSize scrollSize = CGSizeMake(_scrollView.frame.size.width,rows*buttonSize.height);
    _scrollView.contentSize = scrollSize;
    
}

- (void)buttonClicked:(id)sender {
    
	UIButton* button = (UIButton*)sender;
    _clickedLocation = [button.superview convertPoint:button.center toView:nil];
	NSString* path = [_paths objectAtIndex:button.tag];
    
    LogMuPatchPicker(@"%@",path);
    [self dismissViewControllerAnimated:YES completion:nil];
     if (_completion) {
        _completion(@{@"path":path, @"result":@"done"});
    }
}

- (UIImage*)imageFromThumbInZipFile:(NSString*) file {
    
    ZipArchive* zip = [ZipArchive.alloc init];
	UIImage* image = nil;
    
	if([zip UnzipOpenFile:file]) {
        
        NSData* data = [zip dataFromFile:@".png" foundName:nil];
        image = [UIImage imageWithData:data];
        
        if (image) {
            [_thumbs addObject:image];
            [_paths addObject:file];
        }
        [zip UnzipCloseFile];
    } 
    return image;
}

@end

