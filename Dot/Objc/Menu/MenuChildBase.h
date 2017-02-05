#import "MenuChild.h"

struct Tr3;
@class Shader;

@interface MenuChildBase : MenuChild  {
    
    Shader *_shader;
    NSMutableArray* _controls;
    NSMutableArray* _uniforms;
}
- (id)initWithTr3:(Tr3*)tr3;

@end
