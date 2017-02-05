#import "main.h"

@interface UILabel (TextLabel) 

- (id)initWithFrame:(CGRect)frame 
               size:(CGFloat)size 
              align:(UITextAlignment)align 
               text:(NSString*)text;    

@end

#define TextLabelWith(Rect,Size,Align,String) [UILabel.alloc initWithFrame:Rect size:Size align:UITextAlignment##Align text:String];

#define TextLabelSub(Super,Rect,Size,Align,String) {\
UILabel*label = [UILabel.alloc initWithFrame:Rect size:Size align:UITextAlignment##Align text:String];\
[Super addSubview:label];}

#define TextLabelSubColor(Super,Rect,Size,Align,Color,String) {\
UILabel*label = [UILabel.alloc initWithFrame:Rect size:Size align:UITextAlignment##Align text:String];\
label.textColor = Color; \
[Super addSubview:label];}

#define TextLabelRot(Super,Rect,Size,Align,String,Rot) {\
UILabel*label = [UILabel.alloc initWithFrame:Rect size:Size align:UITextAlignment##Align text:String];\
label.transform = CGAffineTransformMakeRotation(Rot);\
[Super addSubview:label];}

