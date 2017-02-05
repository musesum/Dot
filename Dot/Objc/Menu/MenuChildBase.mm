
#import "MenuChildBase.h"
#import "MenuChild.h"
#import "MenuDock.h"

#import "SkyMain.h"
#import "ThumbSlider.h"
#import "ScrubView.h"

#import "AppDelegate.h"
#import "UIImageRgbs.h"
#import "CallIdSel.h"
#import "VideoManager.h"
#import "UIExtras.h"
#import "ScreenView.h"
#import "OrienteDevice.h"
#import "Shader.h"
#import "MuDrawCircle.h"
#import "MuDrawDot.h"
#import "SkyTr3Root.h"
#import "Tr3Cache.h"
#import "CellRuleItem.h"

#import "Tr3Find.h"

#import "ThumbSwitch.h"
#import "ThumbXY.h"
#import "ThumbTwist.h"
#import "ThumbSegment.h"

#import "Tr3Val.h"
#import "Shader.h"

#define LogMenuChildPalette(...)  // DebugLog(__VA_ARGS__)
#define PrintMenuChildPalette(...) // DebugPrint(__VA_ARGS__)

#pragma mark - init

@implementation MenuChildBase

- (id)initWithFrame:(CGRect)frame_  {
    
    assert(@"Must implement with patch");
    return nil;
}

- (id)initWithTr3:(Tr3*)tr3 {
    
    _controls = [NSMutableArray.alloc init];

    // BASE
    
    Tr3* base = tr3->findChild("base");
    if (!base) {
        NSLog(@"*** %s.base not found",tr3->name.c_str());
        return nil;
    }
    Tr3* titleTr3 = base->findChild("title");
    NSString* title = [NSString stringWithUTF8String:*titleTr3];
    Tr3* frameTr3 = base->findChild("frame");
    if (!frameTr3) {return 0;}
    CGRect frame = CGRectMake(*(*frameTr3)[0],*(*frameTr3)[1],*(*frameTr3)[2],*(*frameTr3)[3]);
    self = [super initWithFrame:frame title:title];

    CGFloat w = frame.size.width;
    
    // CONTROLS
    
    Tr3* controls = tr3->findChild("controls");
    if (!controls) {
         NSLog(@"*** %s: controls not found",tr3->name.c_str());
        return self;
    }
    
    for (Tr3* control : controls->children) {
        
        Tr3* type = control->findChild("type");
        char* typeVal = (char*)*type;
        NSLog(@"%s : %s", control->name.c_str(), typeVal);
        
        switch(str2int(typeVal)) {
                
            case str2int("segment"): {
                ThumbSegment* thmb = [ThumbSegment.alloc initWithTr3:control];
                [_controls addObject:thmb];
                [self addSubview:thmb];
                break;
            }
            case str2int("button"): {
                ThumbSwitch* thmb = [ThumbSwitch.alloc initWithTr3:control];
                [_controls addObject:thmb];
                [self addSubview:thmb];
                break;
            }
            case str2int("slider"): {
                ThumbSlider* thmb = [ThumbSlider.alloc initWithTr3:control];
                [_controls addObject:thmb];
                [self addSubview:thmb];
                break;
            }
            case str2int("twist"): {
                ThumbTwist* thmb = [ThumbTwist.alloc initWithTr3:control];
                [_controls addObject:thmb];
                [self addSubview:thmb];
                break;
            }
            case str2int("box"): {
                ThumbXY* thmb = [ThumbXY.alloc initWithTr3:control];
                [_controls addObject:thmb];
                [self addSubview:thmb];
                break;
            }
        }
    }
    
    // SHADER
    
    Tr3* shader = tr3->findChild("shader");
    if (shader) {
        
        _shader = [Shader named:self.title];
        
        Tr3* uniforms = shader->findChild("uniform");
        if (uniforms) {
            for (Tr3*uniform : uniforms->children) {
                if (uniform->val) {
                    uniform->addCall((Tr3CallTo)(&Tr3ShaderCallback),(void*)new CallIdSel(self));
                }
            }
        }
        Tr3* fsh = shader->findChild("fragment"); // fragment
        Tr3* vsh = shader->findChild("vertex"); // vertex
        if (fsh && fsh->val && fsh->val->flags.quote &&
            vsh && vsh->val && vsh->val->flags.quote ) {
            
            Tr3ValQuote* fragQ = (Tr3ValQuote*)(fsh->val);
            Tr3ValQuote* vertQ = (Tr3ValQuote*)(vsh->val);
        
            NSString* fragment = [NSString stringWithUTF8String:fragQ->getWithinCurly().c_str()];
            NSString* vertex   = [NSString stringWithUTF8String:vertQ->getWithinCurly().c_str()];
            [_shader setVertex:vertex fragment:fragment];
        }
    }
    return self;
}


#pragma mark - shader callback

void Tr3ShaderCallback(Tr3*from,Tr3CallData*data) {
    
    __block id target = (__bridge id)(data->_instance);
    dispatch_async(dispatch_get_main_queue(), ^{
        [target updateShaderTr3:from];
    });
}
-(void)updateShaderTr3:(Tr3*)uniform {
    
    NSString* name = [NSString stringWithUTF8String: uniform->name.c_str()];
    
    if (uniform->val->flags.tupple) {
        CGPoint point = CGPointMake(uniform[0], uniform[1]);
        [_shader setPoint:point name:name];
    }
    else if (uniform->val->flags.scalar) {
        Tr3ValScalar* val = (Tr3ValScalar*)uniform->val;
        CGFloat value = *uniform;
        [_shader setFloat:value name:name];
    }
}

#pragma mark - Show Hide

- (void)hideWithCompletion:(CompletionVoid)completion {
    
    assert(@"Must implement with subclass");
    [super hideWithCompletion:completion];
}

#pragma mark - update UI

- (void)reorientCenter {
    
    CGAffineTransform transform =  CGAffineTransformRotate(CGAffineTransformIdentity,[OrienteDevice shared].deviceRadians);
    CGPoint newCenter = [self centerForOrientation];
    
    [UIView animateWithDuration:.5 delay:0 options:AnimUserContinue
                     animations:^{
                         self.center = newCenter;
                         self.transform = transform;
                     }
                     completion:nil];
}


#pragma mark - user actions

// pal cross fade

- (void)onDismissButton {
    
    [self hideWithCompletion:nil];
    
}

@end
