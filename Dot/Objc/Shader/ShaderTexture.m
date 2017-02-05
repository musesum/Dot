
#import "ShaderTexture.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
@implementation ShaderTexture

@synthesize texture;

- (id)initWithProgram:(GLint)program name:(NSString*)name_ num:(int)num {
    
    self = [super init];
    glUseProgram(program); // required
    name = name_;
    const char *cname = [name UTF8String];
    location = glGetUniformLocation(program,cname);
    active = GL_TEXTURE0+num;
    glUniform1i(location, num);
    buf = nil;
    texture = nil;
    return self;
}

- (void)setPal:(void*)palBuf {
    
    type = kTexturePal;
    buf = palBuf;
    self.changed = YES;
}

- (void)setVid:(void*)vidBuf  {
    
    type = kTextureVid;
    buf = vidBuf;
    self.changed = YES;
}

#define GLTx2DEdge(B) \
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_##B); \
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_##B); \
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);\
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

- (void)bindPal {
    
    glActiveTexture(active);
    glBindTexture(GL_TEXTURE_2D, location); // palette texture
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,256, 1, 0, GL_RGBA, GL_UNSIGNED_BYTE, buf);
    GLTx2DEdge(LINEAR);
}

- (void)bindVidCache:(CVOpenGLESTextureCacheRef)vidCache {
    
    if (!texture) {
        size_t width  = CVPixelBufferGetWidth((CVPixelBufferRef)buf);
        size_t height = CVPixelBufferGetHeight((CVPixelBufferRef)buf);
        
        CVReturn ret = CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, vidCache, (CVImageBufferRef)buf,  NULL, GL_TEXTURE_2D, GL_RGBA, width, height, GL_BGRA, GL_UNSIGNED_BYTE, 0, &texture);
        
        if (ret != kCVReturnSuccess) {
            NSLog(@"%s cvReturn: %i",sel_getName(_cmd), (int)ret);
            return;
        }
    }
    if (texture) {
        
        glActiveTexture(active);
        GLenum target = CVOpenGLESTextureGetTarget(texture);
        GLuint texName = CVOpenGLESTextureGetName(texture);
        glBindTexture(target /*GL_TEXTURE_2D*/, texName);
        //NSLog(@"%@: GL_TEXTURE%i target:%i name:%i",name,active-GL_TEXTURE0 ,target,texName);
        GLTx2DEdge(LINEAR)
    }
}

- (void)flush {
    
    if (texture) {
        CVOpenGLESTextureCacheFlush(buf,0); ///???
        CFRelease(texture);
        texture = nil;
    }
}

- (void)bindTexCache:(CVOpenGLESTextureCacheRef)vidCache {
    
    if (location < 0 ||
        buf == nil) {
        
        return;
    }
    switch (type) {
            
        case kTexturePal: {
            
            [self bindPal];
            break;
        }
        case kTextureVid: {
            
            [self bindVidCache:vidCache];
        }
        default:
            break;
    }
}

@end


