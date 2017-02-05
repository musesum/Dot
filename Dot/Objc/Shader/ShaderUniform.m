#import "ShaderUniform.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@implementation ShaderUniform

- (id)initWithProgram:(GLint)program name:(NSString*)name_ {
    
    self = [super init];
    name = name_;
    const char *cname = [name UTF8String];
    location = glGetUniformLocation(program,cname);
    if (location == -1) {
        fprintf(stderr, "??? Shader could Not find uniform:%s for program:%i",cname,program);
    }
    value = nil;
    return self;
}

- (id)initWithProgram:(GLint)program cname:(const char*)cname_ {
    
    self = [super init];
    name = [NSString stringWithUTF8String: cname_];
    location = glGetUniformLocation(program,cname_);
    if (location == -1) {
        fprintf(stderr, "??? Shader could Not find uniform:%s for program:%i",cname_,program);
    }
    value = nil;
    return self;
}

- (void)setFloat:(CGFloat)num {
    
    type = kUniformFloat;
    value = [NSNumber numberWithFloat:num];
}

- (void)setPoint:(CGPoint)point {
    
    type = kUniformPoint;
    value = [NSValue valueWithCGPoint:point];
}


- (void)render {

    if (location < 0 || value == nil) {
        return;
    }

    switch (type) {
            
        case kUniformPoint: {
            
            CGPoint point = [(NSValue*)value CGPointValue];
            glUniform2f(location, point.x,point.y);
            break;
        }
        case kUniformFloat: {
            
            CGFloat num = [(NSNumber*)value floatValue];
            glUniform1f(location, num);
        }
        default:
            break;
    }
}

@end

