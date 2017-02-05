#import "main.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import <CoreVideo/CVOpenGLESTextureCache.h>
#import <CoreVideo/CVPixelBufferPool.h>
#import <CoreMedia/CoreMedia.h>

#import "Shader.h"
#import "ShaderVertex.h"

@class ScreenView; 
@class SkyPatch;

typedef void (^ScreenViewCompletion)(CVImageBufferRef imageBuffer, NSError* error);

@interface ScreenView : UIView {

    // ScreenView --------------------------

    uint32_t* _imageBuffer;
    Shader*  _shaderPass;   // pass through shader for recording
    
    CGSize  _videoDimensions;
    BOOL    _newLayout;
            
    // chromaKey -------------------------------
    
    CMVideoDimensions _offscreendimensions;  
	GLuint _offscreenBuffer;
    
    CVPixelBufferPoolRef      _outputBufferPool;    
    CVOpenGLESTextureCacheRef _texCache;    
    CVOpenGLESTextureCacheRef _texWriteCache;
    
    CGRect _frame2; // for ScreenView2
}

@property(nonatomic,strong) ScreenView* self2; //TODO: separate out as separate instance?
@property(nonatomic,readonly) GLuint frameBuffer;
@property(nonatomic,readonly) GLuint renderBuffer;
@property(nonatomic,readonly) EAGLContext* glContext;
@property(nonatomic,readonly) CGSize viewport;
@property(weak, nonatomic,readonly) Shader* shaderNow;
@property(nonatomic,strong) ShaderVertex*  vertex;       // quads for vertex shader with margins for clipping to viewport
@property(nonatomic) CGSize screenSize;


@property BOOL autoresize; // NO by default - Set to YES to have the EAGL surface automatically resized when the view bounds change, otherwise the EAGL surface contents is rendered scaled

typedef void (^ScreenViewCompletion)(CVImageBufferRef imageBuffer, NSError* error);

// ScreenView 
+ (ScreenView*)shared;
+ (Shader*)shader;

- (BOOL)initRenderWithDimensions:(CMVideoDimensions)dimensions;
- (void)setDrawBuf:(CVImageBufferRef)drawBuf drawPal:(void*)drawPal;
- (void)setCamBuf:(CVImageBufferRef)camBuf camPal:(void*)camPal;

- (void)renderMirror:(bool)mirror;
- (void)renderMirror:(bool)mirror completionBlock:(ScreenViewCompletion)completionBlock;

- (ScreenView*)initSecondScreenViewWithFrame:(CGRect)frame;
- (UIImage*)glScreenshot;

- (id)initWithFrame:(CGRect)frame_;
- (void)clearImageBufferForGlScreenshot; //TODO: remove this!
- (Shader*)addShaderPatch:(SkyPatch*)patch;
- (void)setShaderPatch:(SkyPatch*)patch;
- (Shader*)updateShaderName:(NSString*)name;
@end
