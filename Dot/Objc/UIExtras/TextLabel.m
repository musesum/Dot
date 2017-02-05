
#import "TextLabel.h"


@implementation UILabel (TextLabel)


- (id)initWithFrame:(CGRect)frame 
              size:(CGFloat)size 
             align:(UITextAlignment)align 
              text:(NSString*)text {
    
    self = [super init];
    self.frame           = frame;
    self.font            = [UIFont fontWithName: @"HelveticaNeue" size:size];
    self.backgroundColor = [UIColor clearColor];
    self.textColor       = [UIColor whiteColor];
    self.shadowColor     = [UIColor blackColor];
    self.shadowOffset    = CGSizeMake(1, 1);
    self.textAlignment   = align;
    self.lineBreakMode   = UILineBreakModeWordWrap;
    self.numberOfLines   = 0;
    self.text            = text;
    return self;
}


@end