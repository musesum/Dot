// Tr3Objc.h - convert Tr3Values OBJC
#import "Tr3Objc.h"


CGRect Tr3Rect(Tr3*tr3) {
    
    CGRect rect = CGRectZero;
    
    if (tr3->val && tr3->val->flags.tupple) {
    
        rect = CGRectMake(*(*tr3)[0],*(*tr3)[1],*(*tr3)[2],*(*tr3)[3]);
    }
    return rect;
}

CGPoint Tr3Point(Tr3*tr3) {
    
    CGPoint point = CGPointZero;
    
    if (tr3->val) {
        
        if (tr3->val->flags.tupple) {
        
            point = CGPointMake(*(*tr3)[0],*(*tr3)[1]);
        }
        else if (tr3->val->flags.scalar) {
            
            point = CGPointMake(*tr3,*tr3);
        }
    }
    return point;
}

CGSize Tr3Size(Tr3*tr3) {
    
    CGSize size = CGSizeZero;
    
    if (tr3->val) {
        
        if (tr3->val->flags.tupple) {
            
            size = CGSizeMake(*(*tr3)[0],*(*tr3)[1]);
        }
        else if (tr3->val->flags.scalar) {
            
            size = CGSizeMake(*tr3,*tr3);
        }
    }
    return size;
}

