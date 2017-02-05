#import "InfoView.h"
#import "TextLabel.h"
#import "UIExtras.h"
//#import "Appirater.h"
#import "InfoView.h"
@implementation InfoView

@synthesize muPickerDelgate = _muPickerDelegate;

-(CGSize) scaleToWidthForImage:(UIImage*)image {
    
    CGSize  size = image.size;
    CGFloat scale = (_size.height > 320 
                     ? _size.height / size.height // for portrait iPhone and all iPad
                     : _size.width  / size.width); // for lanscape iPhone
    
    CGSize scaledSize = CGSizeMake(size.width*scale, size.height*scale);
    return scaledSize;
}
- (CGFloat) addPageName:(NSString*)name zFrame:(CGRect*)zFrame{
    
    NSString* path  = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    UIImage* image  = [UIImage.alloc initWithContentsOfFile:path];
    
    if (image) {
        
        CGSize zSize  = [self scaleToWidthForImage:image];
        zFrame->size     = zSize;
        UIImageView* imageView = [UIImageView.alloc initWithFrame:*zFrame];
        imageView.image = image;
        imageView.userInteractionEnabled = YES;
        [self addSubview:imageView]; 
        return zSize.height; 
    }      
    else {
        return 0;
    }
}
- (void)buttonCellFrame:(CGRect)frame action:(SEL)action title:(NSString*)title  fontsize:(CGFloat)fontsize {
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setImage:[UIImage imageNamed:@"InfoMenuCell.png"] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];  
    UILabel* label = TextLabelWith(frame,fontsize,Center,title);
    [self addSubview:button]; 
    [self addSubview:label];
}
- (void)wikiFalseColor {
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://en.wikipedia.org/wiki/False-color"]];
}
- (void)wikiColorGrading {
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://en.wikipedia.org/wiki/Color_grading"]];
}

#define CenterRectSize(X,Y,W,H,S) CGRectMake(zFrame.size.width/2 - W*S/2,zFrame.origin.y+Y*S,W*S,H*S)
- (void) initSettingsViewWithFrame:(CGRect)zFrame {
    
    CGRect segText1a = CGRectMake(12, 52, 244, 24);//(12, 12, 244, 24)
    CGRect segBar1   = CGRectMake(36, 84, 184, 32);//(36, 44, 184, 32)
    
    UILabel* infoRestrictLabel1a = TextLabelWith(segText1a,18,Center,@"Child Lock");
    UIImageView* settingsView = [UIImageView.alloc initWithFrame:CenterRectSize(30, 92, 260,180,1.)];
    settingsView.image = [UIImage imageNamed:@"InfoMenuCellTall.png"];
    settingsView.userInteractionEnabled = YES;
    NSArray* seg1 = [NSArray arrayWithObjects: @"Off", @"On",nil];
    UISegmentedControl* infoRestrictSegment = [UISegmentedControl.alloc initWithItems:seg1];
	infoRestrictSegment.frame = segBar1;
    [infoRestrictSegment addTarget:self action:@selector(infoRestrictAction:) forControlEvents:UIControlEventValueChanged];
	infoRestrictSegment.segmentedControlStyle = UISegmentedControlStyleBar;	
	infoRestrictSegment.tintColor = [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1.0];
    
    NSNumber* num = [[NSUserDefaults standardUserDefaults] objectForKey:kInfoLockStatusKey];
    infoRestrictSegment.selectedSegmentIndex = num ? (InfoLockStatus)[num integerValue] : kInfoLockOff;
	[settingsView addSubview:infoRestrictSegment];
    [settingsView addSubview:infoRestrictLabel1a];

  
    [self addSubview:settingsView];
}

- (id)initWithDelegate:(id)delegate_ size:(CGSize)size_  {
    
    _muPickerDelegate = delegate_;
    _size = size_;
     CGRect zFrame = CGRectMake(0, 0, _size.width, _size.height);
    
    if (![super initWithFrame:zFrame]) 
        return nil;

    //settings screen
    CGFloat pageHeight =  MAX(436,_size.height);
    [self initSettingsViewWithFrame:zFrame];
    [self buttonCellFrame:CenterRectSize(30,20, 260,53,1) action:@selector(goNext)                       title:@"Information"      fontsize:20];
    [self buttonCellFrame:CenterRectSize(30,294,260,53,1) action:@selector(infoRateAppButtonPressed)     title:@"Rate App"         fontsize:20];
    [self buttonCellFrame:CenterRectSize(30,360,260,53,1) action:@selector(infoMuseSupportButtonPressed) title:@"Muse Dot Support" fontsize:20];
    zFrame.origin.y += pageHeight; // settings view as as least 436 
    
    // dock
    pageHeight = [self addPageName:@"InfoDock" zFrame:&zFrame]; 
    zFrame.origin.y += pageHeight;
    
    // palette
    pageHeight = [self addPageName:@"InfoPalette" zFrame:&zFrame];
    zFrame.origin.y += pageHeight;
    
    // Notes
    pageHeight = [self addPageName:@"InfoNotes" zFrame:&zFrame];
    CGFloat scale = pageHeight/436.;
    [self buttonCellFrame:CenterRectSize(30,102,200,28,scale) action:@selector(wikiFalseColor)   title:@"Wikipedia: False Color"   fontsize:12*scale];
    [self buttonCellFrame:CenterRectSize(30,216,200,28,scale) action:@selector(wikiColorGrading) title:@"Wikipedia: Color Grading" fontsize:12*scale];
    zFrame.origin.y += pageHeight;
    
    // Credits
    pageHeight = [self addPageName:@"InfoCredits" zFrame:&zFrame];
    zFrame.origin.y += pageHeight;
    
    self.backgroundColor =  [UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1];
    self.opaque=YES;
    self.contentSize = CGSizeMake(zFrame.size.width,zFrame.origin.y);
    self.scrollEnabled = YES;
    self.userInteractionEnabled = YES;
    
    return self;
}


- (void)infoAlertAction:(id)sender {
    
    UISegmentedControl* infoAlertSegment = (UISegmentedControl *)sender; 
    static bool blocking = NO;
    if (blocking)
        return;
    blocking = YES;
    
    InfoAlertStatus newStatus = [sender selectedSegmentIndex];
    
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:[NSNumber numberWithInt:newStatus] forKey:kInfoLockStatusKey];
    [settings synchronize];
    
    switch (newStatus) {
            
        case kInfoAlertOff: {
            
            break;
        }             
        case kInfoAlertReplies: {
            
            UIAlertView* alert = [UIAlertView.alloc initWithTitle:@"Alert only Replies" 
                                                              message:(@"Alert only for replies to messages that you've sent out.\n\n")
                                                             delegate:nil 
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"OK",nil];
            ((UILabel*)[[alert subviews] objectAtIndex:1]).textAlignment = UITextAlignmentCenter;
            alert.alpha = 1;
            [alert show];

            break;
        }
        case kInfoAlertFriends: {
            
            UIAlertView* alert = [UIAlertView.alloc initWithTitle:@"Alert Replies & Friends" 
                                                              message:(@"In addition to replies, alert when a Friend posts a public message.\n\n")
                                                             delegate:nil 
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"OK",nil];
            ((UILabel*)[[alert subviews] objectAtIndex:1]).textAlignment = UITextAlignmentCenter;
            alert.alpha = 1;
            [alert show];
             break;
        }
        case kInfoAlertMuse: {
            
            UIAlertView* alert = [UIAlertView.alloc initWithTitle:@"Muse Alerts" 
                                                              message:(@"Alert for Replies, Friends, and Muse featured posts.\n\n")
                                                             delegate:nil 
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"OK",nil];
            ((UILabel*)[[alert subviews] objectAtIndex:1]).textAlignment = UITextAlignmentCenter;
            alert.alpha = 1;
            [alert show];
            break;
        }
    }
    infoAlertSegment.selectedSegmentIndex = newStatus;
    blocking = NO;
}

- (void)infoRestrictAction:(id)sender {
    
    UISegmentedControl* infoRestrictSegment = (UISegmentedControl*)sender;
    
    InfoLockStatus newStatus = [sender selectedSegmentIndex];
    
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:[NSNumber numberWithInt:newStatus] forKey:kInfoLockStatusKey];
    [settings synchronize];

    switch (newStatus) {
            
            
        case kInfoLockOff: {

            break;
        }             
        case kInfoLockEverything: {
            
            UIAlertView* alert = [UIAlertView.alloc initWithTitle:@"Child Lock is On" 
                                                              message:(@"\nNow disabling recording\n and sharing.\n")
                                                             delegate:nil 
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"OK",nil];
            ((UILabel*)[[alert subviews] objectAtIndex:1]).textAlignment = UITextAlignmentCenter;
            alert.alpha = 1;
            [alert show];
            break;
        }
    }
}

- (void)infoRateAppButtonPressed {
    
    //[[Appirater sharedInstance] gotoAppRatingURL];
}

- (void)infoMuseSupportButtonPressed {
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://www.muse.com/support"]];
}


- (void)goNext {
    
    [self setContentOffset:CGPointMake(0, _size.height) animated:YES];
    //??? [_muPickerDelegate pickerTitle:@"Information"];
}

@end
