

#import <UIKit/UIKit.h>
#import "BrowserVC.h"

@interface BonjourPicker : UIView <UIPopoverControllerDelegate> {

@private
    
    UILabel* _buttonLabel;
    UIButton*_button;
}

@property (nonatomic, weak) id<BrowserVCDelegate> delegate;
@property (nonatomic, strong) UIPopoverController* popover;
@property (nonatomic, strong, readwrite) BrowserVC* bvc;
@property (nonatomic, copy) NSString* gameName;
@property (nonatomic, strong, readwrite) UILabel* gameNameLabel;

- (id)initWithFrame:(CGRect)frame type:(NSString*)type;

@end
