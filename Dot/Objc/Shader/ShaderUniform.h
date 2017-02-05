#import "main.h"
#import <string.h>
typedef enum {
    
    kUniformUndef,
    kUniformPoint,
    kUniformFloat,
} UniformType;

@interface ShaderUniform : NSObject {
    
    NSString *name;
    GLint location;
    NSValue *value;
    UniformType type;
}

- (id)initWithProgram:(GLint)program name:(NSString*)name_;
- (id)initWithProgram:(GLint)program cname:(const char*)cname_ ;

- (void)setFloat:(CGFloat)num;
- (void)setPoint:(CGPoint)point;
- (void)render;

@end
