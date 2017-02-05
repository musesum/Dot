
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import <CoreVideo/CVOpenGLESTextureCache.h>
#import <CoreVideo/CVPixelBufferPool.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <CoreMedia/CoreMedia.h>

#import <QuartzCore/QuartzCore.h>
#import <sys/utsname.h>
#import "ShaderVertex.h"

@class LineKey;

@interface Shader : NSObject {

    NSString* _name;
    NSString* _vertex;
    NSString* _fragment;

    NSMutableDictionary *_uniforms;
    NSMutableDictionary *_textures;
    
    int _texCount;
    GLint _aPosition;           // attribute position
    GLint _aTexCoord;           // attribute texture coord
    NSString* _logVertexError;
    NSString* _logFragmentError;
    LineKey* _lineKey;
    GLint _program;
}

@property(nonatomic,strong) NSString*name;
@property(nonatomic,strong) NSString*vertex;
@property(nonatomic,strong) NSString*fragment;
@property(nonatomic,assign) GLint program;
@property(nonatomic,assign) bool loaded;

+ (Shader*)named:(NSString*)name;

- (bool)setVertex:(NSString*)vertex_ fragment:(NSString*)fragment_;
- (id)initWithName:(NSString*)name;
- (CVOpenGLESTextureRef)textureForName:(NSString*)name;

- (void)setFloat:(CGFloat)num   name:(NSString*)name;
- (void)setPoint:(CGPoint)point name:(NSString*)name;
- (void)setPal:(void*)buf      name:(NSString*)name;
- (void)setVid:(void*)vidBuf   name:(NSString*)name;
- (void)bindTexCache:(CVOpenGLESTextureCacheRef)vidCache;
- (void)drawVertex:(ShaderVertex*)vertex pixType:(DrawPixType)pixType mirror:(bool)mirror;
- (void)flush;
- (void) printShader;
@end
