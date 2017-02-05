#import "main.h"

typedef enum {
    
    kTextureUndef,
    kTexturePal,
    kTextureVid,
} TextureType;


@interface ShaderTexture  : NSObject {
    
    NSString *name;
    GLint location;
    GLuint active;
    TextureType type;
    void *buf;
    CVOpenGLESTextureRef texture;
}

@property(atomic)bool changed;
@property(nonatomic) CVOpenGLESTextureRef texture;

- (id)initWithProgram:(GLint)program name:(NSString*)name_ num:(int)num ;
- (void)bindTexCache:(CVOpenGLESTextureCacheRef)vidCache;
- (void)flush;
- (void)setPal:(void*)palBuf;
- (void)setVid:(void*)vidBuf;

@end

