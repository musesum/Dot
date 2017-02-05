
#import "MenuDock+Add.h"
#import "SkyMain.h"
#import "MenuParent.h"
#import "MenuChild.h"
#import "UIExtras.h"
#import "OrienteDevice.h"
#import "Tr3.h"
#import "Shader.h"


#define LogMenuDockAdd(...) //DebugLog(__VA_ARGS__)

@implementation MenuDock(Add)

#pragma mark - Dock

- (MenuParent*)addTr3Child:(Tr3*)tr3 menuChild:(MenuChild*)menuChild  {
    
    if (!tr3 || !menuChild) {return nil;}
    NSString* name = [NSString stringWithUTF8String:tr3->name.c_str()];
    MenuParent* parent = [_parentNames objectForKey:name];
    
    if (!parent)  {
        
        Tr3*base = tr3->findChild("base");
        if (base) {
            Tr3*type = base->findChild("type");
            Tr3*icon = base->findChild("icon");
            
            if (type && icon) {
                UIImage* img = [UIImage getIconPath:"/tr3/dot/png" name:(char*)*icon];
                NSString* typeStr = [NSString stringWithUTF8String:(char*)*type];
    
                parent = [MenuParent.alloc initWithName:name type:typeStr img:img menuChild:menuChild target:self];
                if (parent) {
                    [self.parents addObject:parent];
                    [self.superview addSubview:parent];
                    [_parentNames setObject:parent forKey:name];
                    menuChild.menuParent = parent;
                }
            }
        }
    }
    return parent;
}

- (void)addSkyRoot:(Tr3*)skyRoot {
    
    Tr3* dots = skyRoot->bind("dot");
    
    for (Tr3* dot : dots->children) {
        if (dot->name[0]=='_') {
            continue;
        }
        else if (dot->name=="shader" ||
                 dot->name=="pal") {
            
            for (Tr3*child : dot->children) {
                
                MenuChild* mcb = [MenuChild.alloc initWithTr3:child];
                [self addTr3Child:child menuChild:mcb];
            }
        }
        else if (dot->name=="cell") {
            for (Tr3*child : dot->children) {
                
                if (child->name=="rule") {
                    
                    for (Tr3*gchild : child->children) {
                        MenuChild* mcb = [MenuChild.alloc initWithTr3:gchild];
                        [self addTr3Child:gchild menuChild:mcb];
                    }
                }
                else if (child->name=="shift" ||
                         child->name=="brush") {
                    MenuChild* mcb = [MenuChild.alloc initWithTr3:child];
                    [self addTr3Child:child menuChild:mcb];
                    
                }
            }
        }
    }
}

- (void)pushRingSelection:(MenuParent*)parent {
    
    LogMenuDockAdd(@"MenuDock+Add::%s",sel_getName(_cmd));
    
    if (parent==nil) {
        
        // hardwired new parent from picker is always in position 1 (second from left)
        parent = [self.parents objectAtIndex:1];
        parent.tag = 1;
    }
    if (parent != _selectedNow && // don't push duplicate
        _selectedNow.tag != 0)  {   // nor save position 0, which is patch picker
        
        _selectedPrev = _selectedNow;
    }
    _selectedNow = parent;
    
    [UIView animateWithDuration:.33 delay:0 options:AnimUserContinue
     
                     animations:^{
                         
                         [self arrangeParents];
                         self.parentRing.center = _selectedNow.calcCenter;
                     }
                     completion:^(BOOL finished){
                         
                         [self arrangeParents];
                         [self.superview bringSubviewToFront:self];
                         
                     }];
}

-(void) popRingSelection {
    
    LogMenuDockAdd(@"MenuDock+Add::%s",sel_getName(_cmd));
    
    _selectedNow = _selectedPrev;
    
    [UIView animateWithDuration:.33 delay:0 options:AnimUserContinue
                     animations:^{
                         
                         [self arrangeParents];
                         self.parentRing.center = _selectedNow.calcCenter;
                     }
                     completion:^(BOOL finished) {
                         
                         [self arrangeParents];
                         [self.superview bringSubviewToFront:self];
                     }];
}

- (void)MenuParentDraggedOutName:(NSString*)patchPath {
    
    MenuParent*menuParent = [_parentNames objectForKey:patchPath];
    if (menuParent)
        [_parentNames removeObjectForKey:patchPath];
}


- (void)initDock:(NSString*)dock {
    
    [_parentNames removeAllObjects];
    [self removeAll];
    [self initParentPositions];
    
    // initPearlDockAtParentNow
    for (int i=0; i < self.parents.count; i++) {
        if ([self.parents objectAtIndex:i]==self.parentNow) {
            [self initPositionsAtIndex:i];
            break;
        }
    }
    _cursorCenter.x = self.parentNow.calcCenter.x;
    _cursor.center = _cursorCenter;
    [self relocateParent:self.parentNow hideChild:YES];
    [self calcCursorPosition];
    [self arrangeParents];
}


- (void)setShaderName:(NSString*)shaderName {
    
}

- (void)splashWithCompletion:(CompletionVoid)completion {
    
    [self.parentTimer invalidate];
    self.parentTimer = nil;
    
    [OrienteDevice.shared orientationChanged:nil];
    float radians = OrienteDevice.shared.interfaceRadians;
    float cw = _cursor.frame.size.width;
    float ch = _cursor.frame.size.height;
    CGSize sz = UIScreen.mainScreen.fixedCoordinateSpace.bounds.size;// UIScreen.mainScreen.bounds.size;
    CGRect startFrame = CGRectMake(sz.width/2 - cw/2, sz.height/2 - ch/2, cw, ch);
    [self.superview bringSubviewToFront:self];
    
    _cursor.frame = startFrame;
    
    for (MenuParent* parent in self.parents) {
        parent.alpha = 0;
    }
    self.parentRing.alpha = 0;
    
    [UIView animateWithDuration:.66  delay:0 options:AnimUserContinue animations:^{
        
        _cursor.center = _cursorCenter;
        
    } completion:^(BOOL compete) {
        
        for (MenuParent* parent in self.parents) {
            parent.center = _cursor.center;
        }
        self.parentRing.center = _cursor.center;
        
        [UIView animateWithDuration:.33 delay:0 options:AnimUserContinue animations:^{
            
            for (MenuParent* parent in self.parents) {
                parent.alpha = 1;
            }
        } completion:^(BOOL compete) {
            if (completion) {
                completion();
            }
        }];
    }];
}



@end
