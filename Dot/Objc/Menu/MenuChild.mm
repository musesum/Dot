#import "MenuChild.h"
#import "MenuDock.h"
#import "Tr3Cache.h"
#import "SkyTr3Root.h"
#import "UIExtras.h"
#import "OrienteDevice.h"
#import "TouchView.h"

#import "ThumbXY.h"
#import "ThumbTwist.h"
#import "ThumbSegment.h"

#import "Shader+tr3.h"

#define LogMenuChild(...) //DebugLog(__VA_ARGS__)
#define PrintMenuChild(...) //DebugPrint(__VA_ARGS__)

@implementation MenuChild

- (id)initWithTr3:(Tr3*)tr3 {
    // base
    Tr3* base = tr3->findChild("base");
    if (!base) {
        NSLog(@"*** %s.base not found",tr3->name.c_str());
        return nil;
    }
    // frame
    Tr3* frameTr3 = base->findChild("frame");
    if (frameTr3 == nil) {
        NSLog(@"*** %s.frame not found",tr3->name.c_str());
        return nil;
    }
    CGRect frame = CGRectMake(*(*frameTr3)[0],
                              *(*frameTr3)[1],
                              *(*frameTr3)[2],
                              *(*frameTr3)[3]);
    // title
    Tr3* titleTr3 = base->findChild("title");
    NSString* title = titleTr3 ?  [NSString stringWithUTF8String:*titleTr3] : @"yo";
    
    self = [self initWithFrame:frame title:title];
    [self initControlsForTr3:tr3];
    [Shader initShaderNamed:self.title tr3:tr3];
    return self;
}

- (id)initWithFrame:(CGRect)frame_ title:(NSString*)title_ {
    
    self = [super initWithFrame:frame_ blur:YES];
    _pinned = NO;
    self.layer.cornerRadius = 16;
    self.layer.masksToBounds= YES;
    self.hidden = YES;
    
    [self initDismissButton];
    [self initTitle:title_];
    
    [TouchView.shared insertSubview:self atIndex:0];
    _rotation = CGAffineTransformRotate(CGAffineTransformIdentity, OrienteDevice.shared.deviceRadians);
    return self;
}

- (void)initDismissButton {
    
    self.dismissButton = [UIButton.alloc initWithFrame:CGRectMake(0,0,44,44)];
    [_dismissButton setImage:[UIImage imageNamed:@"dot.menu.X"] forState:UIControlStateNormal];
    [_dismissButton addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
    _dismissButton.showsTouchWhenHighlighted = NO;
    _dismissButton.alpha = .5;
    [self addSubview:_dismissButton];
}

- (void)initTitle:(NSString*)title_ {
    
    self.title = title_;
    _titleLabel = [UILabel.alloc init];
    _titleLabel.numberOfLines   = 1;
    _titleLabel.frame           = CGRectMake(0,0, self.frame.size.width,40);
    _titleLabel.font            = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor       = [UIColor whiteColor];
    _titleLabel.shadowOffset    = CGSizeMake(0, .5);
    _titleLabel.shadowColor     = [UIColor darkGrayColor];
    _titleLabel.textAlignment   = NSTextAlignmentCenter;
    _titleLabel.lineBreakMode   = NSLineBreakByTruncatingTail;
    _titleLabel.text = _title;
    _titleLabel.alpha = .62;
    [self addSubview:_titleLabel];
}


- (void)initControlsForTr3:(Tr3*)tr3 {
    
    _controls = [NSMutableArray.alloc init];
    Tr3* controls = tr3->findChild("controls");
    if (!controls) {
        NSLog(@"*** %s: controls not found",tr3->name.c_str());
        return;
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
}

#pragma mark - menuDock Delegate

#define RANGE(a,b,c) MAX(a,MIN(b,c))

- (CGPoint)centerForOrientation {
    
    CGFloat parentY = _menuParent.frame.origin.y;
    CGFloat parentX = _menuParent.center.x;
    
    switch (_showState) {
        case kAnimateToHide:
        case kHidden:
            
            parentY = MenuDock.shared.cursor.frame.origin.y;
            parentX = MenuDock.shared.cursorCenter.x;
            break;
            
        case kAnimateToShow:
        case kShowing:
            
            parentY =_menuParent.frame.origin.y;
            parentX =_menuParent.calcCenter.x;
            break;
    }
    
    CGSize  screenSize = UIScreen.mainScreen.fixedCoordinateSpace.bounds.size;
    CGFloat w  = screenSize.width;
    CGFloat h  = screenSize.height;
    CGFloat W2 = _menuSize.width/2;
    CGFloat H2 = _menuSize.height/2;
    CGPoint newCenter;
    
    UIDeviceOrientation orientation = [UIScreen currentDeviceOrientation];
    
    switch (orientation) {
            
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            
            newCenter = CGPointMake(RANGE(W2,parentX,w-W2), parentY-H2); break;
            
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            
            newCenter = CGPointMake(RANGE(H2,parentX,w-H2), parentY-W2); break;
            
        default: break;
    }
    
    return newCenter;
}

- (void)reorientCenter {
    
    if (_showState != kShowing) {
        return;
    }
    PrintMenuChild(" C_Ro(%i):%s",_showState,[_menuParent.patchName UTF8String]);
    
    _rotation = CGAffineTransformRotate(CGAffineTransformIdentity, [OrienteDevice shared].deviceRadians);
    
    [UIView animateWithDuration:AnimateTimeMenuDock delay:0 options:AnimUserContinue animations:^{
        self.transform = _rotation;
        self.center = [self centerForOrientation];
    } completion:nil];
}

- (void)reScale:(CGFloat)scale_ {
    
    PrintMenuChild(" C_*(%i):%s==%.3f ",_showState,[_menuParent.patchName UTF8String],_scale);

    _scale = MAX(.001,scale_); // keep rotation, so don't scale to ==0.
    _radius = _menuSize.width*_scale/2;
    _rotation = CGAffineTransformRotate(CGAffineTransformIdentity, [OrienteDevice shared].deviceRadians);
    [self setTransform:CGAffineTransformScale(_rotation, _scale, _scale)];
}

- (CGPoint)constrict:(CGPoint)point_ {
    // override this
    return point_; // unconstricted
}


#pragma mark - MenuParentDelegate

- (void)showMenu {
    
    /* moving parent to new position in dock so don't show child */
    if (_menuParent.dragging) {
        return;
    }
      
    PrintMenuChild(" C_S(%i):%s",_showState,[_menuParent.patchName UTF8String]);
    
    switch (_showState) {
            
        case kHidden:
            
            self.hidden = NO;
            [self reScale:0];
            [self removeFromSuperview];
            
            // start from behind parent view
            [TouchView.shared insertSubview:self atIndex:0];
            self.center = _menuParent.center;
            break;
            
        case kAnimateToHide: {
            
            // interrupt show animation and show from current location and size
            CALayer *currentLayer = self.layer.presentationLayer;
            [self.layer removeAllAnimations];
            self.layer.transform = currentLayer.transform;
            self.layer.position = currentLayer.position;
            
            break;
        }
        case kAnimateToShow:
        case kShowing:
            return;
            
    }
    _showState = kAnimateToShow;
    _pinned = YES;
    
    [UIView animateWithDuration:AnimateTimeMenuDock delay:0 options:AnimUserContinue animations:^{
        
        _radius = _menuSize.width * _scale/2;
        _rotation = CGAffineTransformRotate(CGAffineTransformIdentity, [OrienteDevice shared].deviceRadians);
        self.transform = _rotation;
        self.center = [self centerForOrientation];
        
    } completion:^(BOOL finished) {
        
        if (finished && _showState==kAnimateToShow) {
            _showState = kShowing;
        }
    }];
}

- (void)hideMenu {
    
    _pinned = NO;
    
    if (_menuParent.dragging) {
        return;
    }
    PrintMenuChild(" C_H(%i):%s",_showState,[_menuParent.patchName UTF8String]);
    
    switch (_showState) {
            
        case kAnimateToHide:
         case kHidden:
              return;
            
        case kAnimateToShow: {
            
            // interrupt show animation and hide from current location and size
            CALayer *currentLayer = self.layer.presentationLayer;
            [self.layer removeAllAnimations];
            self.layer.transform = currentLayer.transform;
            self.layer.position = currentLayer.position;
            break;
        }
        case kShowing:
            // start new animation
            break;
    }
    
    _showState = kAnimateToHide;

    [UIView animateWithDuration:AnimateTimeMenuDock delay:0 options:(AnimUserContinue) animations:^{
        
        [self reScale:0];
        self.center = _menuParent.center;
        
    } completion:^(BOOL finished) {
        
        if (finished && _showState == kAnimateToHide) {
            
            _showState = kHidden;
            self.hidden = YES;
        }
    }];
}
/* only hide if user hasn't dragged out as a standalone UI
 */
- (void) hideUnpinned {
    if (!_pinned) {
        [self hideMenu];
    }
}

/* when appEnteringForeground check to see if child is active
 * and refresh the child's UI, which is useful for children
 * that display system state, such as IP address,
 * which can change while the app is in background
 */
- (void)refresh {
    
    if (_showState==kShowing) {
        [self showMenu];
    }
}

-(void)parentTap2 {
    
}

// block touches from getting passed onto superview
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{}
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event{}
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event{}

@end




