#import <QuartzCore/QuartzCore.h>
#import <sys/utsname.h>

#import "ScreenView.h"
#import "ImageFromType.h"
//import "PointTime.h"

#import "CellMain.h"
#import "OrienteDevice.h"
#import "VideoManager.h"
#import "UIExtras.h"
#import "VideoManager.h"
#import "SkyPatch.h"

#define LogScreenView(...) DebugLog(__VA_ARGS__)
#define PrintScreenView(...)  //DebugPrint(__VA_ARGS__)

#define GLTx2DEdge(B) \
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_##B); \
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_##B); \
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);\
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);   

#define TestError(A,B) if (A) { NSLog(@"%s %s",sel_getName(_cmd),#A); B;  }
#define TestCVReturn(A,B) {CVReturn ret = A; if (ret) { NSLog(@"%s cvReturn: %i",sel_getName(_cmd), (int)ret); B;  }}


static CVPixelBufferPoolRef CreatePixelBufferPool(CMVideoDimensions dimensions, OSType pixelFormat) {
    
	CVPixelBufferPoolRef outputPool = NULL;
	
    CFMutableDictionaryRef sourcePixelBufferOptions = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks );
    CFNumberRef number = CFNumberCreate( kCFAllocatorDefault, kCFNumberSInt32Type, &pixelFormat );
    CFDictionaryAddValue( sourcePixelBufferOptions, kCVPixelBufferPixelFormatTypeKey, number );
    CFRelease( number );
    
    number = CFNumberCreate( kCFAllocatorDefault, kCFNumberSInt32Type, &dimensions.width );
    CFDictionaryAddValue( sourcePixelBufferOptions, kCVPixelBufferWidthKey, number );
    CFRelease( number );
    
    number = CFNumberCreate( kCFAllocatorDefault, kCFNumberSInt32Type, &dimensions.height );
    CFDictionaryAddValue( sourcePixelBufferOptions, kCVPixelBufferHeightKey, number );
    CFRelease( number );
    
    CFDictionaryAddValue( sourcePixelBufferOptions, kCVPixelFormatOpenGLESCompatibility, kCFBooleanTrue );
    
    CFDictionaryRef ioSurfaceProps = CFDictionaryCreate( kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks );      
    if (ioSurfaceProps) {
        CFDictionaryAddValue( sourcePixelBufferOptions, kCVPixelBufferIOSurfacePropertiesKey, ioSurfaceProps);
        CFRelease(ioSurfaceProps);
    }
    //TODO: kXCPixelBufferIOSurfacePropertiesKey?
    CVPixelBufferPoolCreate( kCFAllocatorDefault, NULL, sourcePixelBufferOptions, &outputPool );
    
    CFRelease( sourcePixelBufferOptions );
	return outputPool;
}

@implementation ScreenView


+ (ScreenView*)shared {
    
    static ScreenView* screenView=0;
    
    if (!screenView) {
        screenView = [ScreenView alloc];
        screenView.frame = UIScreen.mainScreen.fixedCoordinateSpace.bounds;
    }
    return screenView;
}

+ (Shader*)shader {
    
    ScreenView* screenView = [ScreenView shared];
    Shader* shader = screenView.shader;
    return shader;
}

- (Shader*)shader {
    
    return _shaderNow;
}

+ (Class)layerClass {
    
	return [CAEAGLLayer class];
}
#pragma mark - Second Screen

- (id)initWithFrame:(CGRect)frame_ shared:(EAGLContext*)glShared {
    
    _frame2 = frame_;
    self = [super initWithFrame:_frame2];
  		CAEAGLLayer* eaglLayer = (CAEAGLLayer*)[self layer];
    
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES],
                                    kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8,
                                    kEAGLDrawablePropertyColorFormat, nil];
    if(_glContext == nil) {
        
        _glContext = [EAGLContext.alloc initWithAPI:[glShared API] sharegroup: [glShared sharegroup]];
        if(_glContext == nil) {
            return nil;
        }
    }
    self.userInteractionEnabled = YES;
    self.backgroundColor = UIColor.blackColor;
    self.opaque = YES;
    return self;
}


- (ScreenView*)initSecondScreenViewWithFrame:(CGRect)frame {
    
    _self2 = [ScreenView.alloc initWithFrame:frame shared:_glContext];
    _self2.screenSize = CGSizeMake(frame.size.height, frame.size.width);
    
    if(![_self2 _createSurface]) {
        return nil;
    }
    _self2.vertex = [ShaderVertex.alloc initWithVideoDimensions:_videoDimensions screenSize:_self2.screenSize];
    glViewport(0, 0, _self2.screenSize.height,_self2.screenSize.width);
    return _self2;
}

#pragma mark - ScreenShot

- (UIImage*)glScreenshot {
    
    CGSize screenSize = UIScreen.mainScreen.fixedCoordinateSpace.bounds.size;
    CGSize size = CGSizeMake(screenSize.width, screenSize.height); // camera images are rotated 90 degrees
    
    size_t bufSize = (size_t)(size.width*size.height*4);
    Byte* buffer = (Byte*)malloc(bufSize); 
    
    [self clearImageBufferForGlScreenshot];
    _imageBuffer = (uint32_t*)malloc(bufSize);
    
    glReadPixels(0,0,size.width,size.height,GL_RGBA,GL_UNSIGNED_BYTE,buffer);
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, buffer, bufSize, NULL);
    CGImageRef iref = CGImageCreate(size.width,size.height,8,32,size.width*4,CGColorSpaceCreateDeviceRGB(),kCGBitmapByteOrderDefault,ref,NULL,true,kCGRenderingIntentDefault);
    
    CGContextRef context = CGBitmapContextCreate(_imageBuffer, size.width, size.height, 8, size.width*4, CGImageGetColorSpace(iref), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    UIInterfaceOrientation orientation = [OrienteDevice shared].interface;
    VideoManager* videoManager = [VideoManager shared];
    if (videoManager.captureFlags & kDeviceCaptureCameraFront) {
        
        if (orientation == UIInterfaceOrientationPortrait ||
            orientation == UIInterfaceOrientationPortraitUpsideDown) {
            // do nothing
        } 
        else {
            
            CGContextTranslateCTM(context, size.width,0.); 
            CGContextScaleCTM(context, -1.0, 1.0);
            
            CGContextTranslateCTM(context, 0.0, size.height); 
            CGContextScaleCTM(context, 1.0, -1.0);
        }
    }
    else {
        
        CGContextTranslateCTM(context, 0.0, size.height); 
        CGContextScaleCTM(context, 1.0, -1.0);
    }
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, size.width, size.height), iref);
    CGImageRef outputRef = CGBitmapContextCreateImage(context);
    UIImage* image = [UIImage imageWithCGImage:outputRef];
    free(buffer);  
    bool mirror = (videoManager.captureFlags & kDeviceCaptureCameraFront); 
    UIImage* rotatedImage = rotate(image,orientation,NO/*mirror*/);    
    return rotatedImage;
}
- (void)clearImageBufferForGlScreenshot {
    
    // this kinda sucks, but even though ios 4.0 allows for auto creation buffer for CGContextRef 
    // it doesn't work for glScreenShot, as it passes an image to be processed later
    
    if (_imageBuffer) {
        
        free(_imageBuffer);
        _imageBuffer = nil;
    }
}

#pragma mark - Shader

- (Shader*)addShaderPatch:(SkyPatch*)patch {
    
    Shader *shader = [Shader named:patch.shaderName];
    
    if ([shader setVertex:patch.shaderVsh fragment:patch.shaderFsh]) {
        return shader;
    } else {
        return nil;
    }
    return shader;
}

- (void)setShaderPatch:(SkyPatch*)patch{
    
    Shader *shader = [self addShaderPatch:patch];
    if (shader) {
        _shaderNow = shader;
    }
}

- (Shader*) updateShaderName:(NSString*)name {
    Shader *shader = [Shader named:name];
    if (shader) {
        _shaderNow = shader;
    }
    return _shaderNow;
}

#pragma mark - EAGLView

- (BOOL)initializeBuffers {
    
	if(![EAGLContext setCurrentContext:_glContext]) {
		return NO;
	}
    
	glDisable(GL_DEPTH_TEST);
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    [_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
	TestError(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE,return NO;)
    
    TestCVReturn(CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _glContext, NULL, &_texCache),return NO)
    
	return YES;
}

- (void)layoutSubviews {
    
	CGRect bounds = [self bounds];
	
	if(_autoresize && ((roundf(bounds.size.width) != _viewport.width) ||
                       (roundf(bounds.size.height) != _viewport.height))) {
		[self _destroySurface];
        _newLayout = YES;
        LogScreenView(@"Resizing surface from %gx%g to %gx%g", _viewport.width, _viewport.height, roundf(bounds.size.width), roundf(bounds.size.height));
        [self initializeBuffers];
	}
}

- (id)initWithFrame:(CGRect)frame_ {
    
    self = [super initWithFrame:frame_];
    
    CAEAGLLayer* eaglLayer = (CAEAGLLayer*)[self layer];
    
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES],
                                    kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8,
                                    kEAGLDrawablePropertyColorFormat, nil];
    if(_glContext == nil) {
        // currently using floating only for ES2
        _glContext = [EAGLContext.alloc initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if(_glContext == nil) {
            return nil;
        }
    }
    
    if(![self _createSurface]) {
        return nil;
    }

    self.userInteractionEnabled = YES;
    self.backgroundColor = UIColor.blackColor;
    self.opaque = YES;
    
    // was sole call to [self initSharedObjects] ___________________________
    
    
    VideoManager* videoManager = [VideoManager shared];
    CMVideoDimensions dim = videoManager.videoDimensions;
    _videoDimensions = CGSizeMake(dim.width, dim.height);
    _screenSize = CGSizeMake(frame_.size.width, frame_.size.height);
    self.vertex = [ShaderVertex.alloc initWithVideoDimensions:_videoDimensions screenSize:_screenSize];
    glViewport(0, 0, _screenSize.width,_screenSize.height);
    _imageBuffer = nil;
    
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _glContext, NULL, &_texCache);
     return self;
}

- (BOOL)_createSurface {
    
	CAEAGLLayer*eaglLayer = (CAEAGLLayer*)[self layer];
	CGSize newSize;
	GLuint oldRenderbuffer;
	GLuint oldFramebuffer;
	
	if(![EAGLContext setCurrentContext:_glContext]) {
		return NO;
	}
	
	newSize = [eaglLayer bounds].size;
	newSize.width = roundf(newSize.width);
	newSize.height = roundf(newSize.height);
	
	glGetIntegerv(GL_RENDERBUFFER_BINDING, (GLint*) &oldRenderbuffer);
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, (GLint*) &oldFramebuffer);
	
	glGenRenderbuffers(1, &_renderBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
	
	if(![_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer]) {
		glDeleteRenderbuffers(1, &_renderBuffer);
		glBindRenderbuffer(GL_RENDERBUFFER_BINDING, oldRenderbuffer);
		return NO;
	}
	
	glGenFramebuffers(1, &_frameBuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
	
    VideoManager* videoManager = [VideoManager shared];
    CMVideoDimensions dim = videoManager.videoDimensions;
    _videoDimensions = CGSizeMake(dim.width, dim.height);
	_viewport = CGSizeMake(dim.width, dim.height);
    
 	if(_newLayout) {
		_newLayout = NO;
	}
	else {
		glBindFramebuffer(GL_FRAMEBUFFER, oldFramebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, oldRenderbuffer);
	}
    
	[self setAutoresize:YES];
    
	return YES;
}

- (void)_destroySurface {
    
	EAGLContext* oldContext = [EAGLContext currentContext];
	
	if (oldContext != _glContext)
		[EAGLContext setCurrentContext:_glContext];
    
	glDeleteRenderbuffers(1, &_renderBuffer);
	_renderBuffer = 0;
	
	glDeleteFramebuffers(1, &_frameBuffer);
	_frameBuffer = 0;
	
	if (oldContext != _glContext)
		[EAGLContext setCurrentContext:oldContext];
}

- (void)dealloc {
    
    //TODO: update
    glDeleteFramebuffers(1, &_frameBuffer);
    
	[self _destroySurface];
	
	
}

#pragma mark - LucySky Delegate

- (BOOL)initRenderWithDimensions:(CMVideoDimensions)dimensions {
    
    if (_outputBufferPool) {
        CFRelease(_outputBufferPool);
        _outputBufferPool = NULL;
    }    
    if (_offscreenBuffer) {
        glDeleteFramebuffers(1, &_offscreenBuffer);
        _offscreenBuffer = 0;
    }      
    if (_texWriteCache) {
        CFRelease(_texWriteCache);
        _texWriteCache = 0;
    }     
    _offscreendimensions = dimensions;
    
    _outputBufferPool = CreatePixelBufferPool(dimensions, kCVPixelFormatType_32BGRA);
    if (!_outputBufferPool) {
        //NSLog(@"%s: Couldn't create a pixel buffer pool.",sel_getName(_cmd));
        return NO;
    }
    // initialized offscreen buffers
    glGenFramebuffers(1, &_offscreenBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenBuffer);
    
    TestCVReturn(CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _glContext, NULL, &_texWriteCache), return NO)

    return YES;
}

- (void)laterFaceDetection {
    
    /*//ws --------------------------
     CIImage* result = [CIImage imageWithCVPixelBuffer:vidBuf];
     
     result = [CIFilter filterWithName: @"CIHueAdjust" keysAndValues: 
     @"inputImage", result, 
     @"inputAngle", [NSNumber numberWithFloat:8.094], 
     nil].outputImage;
     
     //CIContext* ciContext = [CIContext contextWithEAGLContext:_glContext];
     CIContext* ciContext = [CIContext contextWithOptions:NULL];
     //CVPixelBufferLockBaseAddress( vidBuf, 0 );
     [ciContext render:result toCVPixelBuffer:vidBuf bounds:[result extent] colorSpace:nil];
     //CVPixelBufferUnlockBaseAddress( vidBuf, 0 );
     
     //*///---------------------------------------   
}

- (void)setDrawBuf:(CVImageBufferRef)drawBuf drawPal:(void*)drawPal {
    
    PrintScreenView("|");
    static float count = 0;
    count += 1.;
    [EAGLContext setCurrentContext:_glContext];
    [_shaderNow setVid:drawBuf name:@"drawBuf"];
    [_shaderNow setPal:drawPal name:@"drawPal"];
    //TODO: add counter [_shaderNow setFloat:count name:@"count"];
}

- (void)setCamBuf:(CVImageBufferRef)camBuf camPal:(void*)camPal {
    
    PrintScreenView("°");
    [EAGLContext setCurrentContext:_glContext];
    [_shaderNow setVid:camBuf name:@"camBuf"];
    [_shaderNow setPal:camPal name:@"camPal"];
}


- (void)renderMirror:(bool)mirror {
    
    static bool displaying = NO;
    if (displaying)
        return;
    displaying = YES;
    
    if (_texCache) {
        
        [EAGLContext setCurrentContext:_glContext];
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        
        [_shaderNow bindTexCache:_texCache];
        [_shaderNow drawVertex:_vertex pixType:kDrawPixShow mirror:mirror];
    
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
        [_glContext presentRenderbuffer:GL_RENDERBUFFER];
    }
    if (_self2) { //-------------_self2 render
        
        [EAGLContext setCurrentContext:_self2.glContext];
        glBindFramebuffer(GL_FRAMEBUFFER, _self2.frameBuffer);
        
        [_shaderNow bindTexCache:_texCache];
        [_shaderNow drawVertex:_self2.vertex pixType:kDrawScreen2 mirror:NO];
        
        glBindRenderbuffer(GL_RENDERBUFFER, _self2.renderBuffer);
        [_self2.glContext presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    [_shaderNow flush]; // need to rebind
    glFlush();

    displaying = NO;
}

#define BailOnErr(A,B) err = A B; if (err) { NSLog(@"%s::%s err: %i",sel_getName(_cmd),(char*)#A, (int)err); goto bail;  }

- (void)renderMirror:(bool)mirror completionBlock:(ScreenViewCompletion)completionBlock {

    // lock out multiple calls
    static bool displaying = NO;
    if (displaying)
        return;
    displaying = YES;
    
    [_shaderNow bindTexCache:_texCache];
    
    CVOpenGLESTextureRef srcTexture = [_shaderPass textureForName:@"passBuf"];
    
    OSStatus err = noErr;
    CVImageBufferRef destPixelBuffer = nil;
    CVOpenGLESTextureRef destTexture = nil;
    
    BailOnErr(CVPixelBufferPoolCreatePixelBuffer,
              (kCFAllocatorDefault,
               _outputBufferPool,
               &destPixelBuffer))
    
    BailOnErr(CVOpenGLESTextureCacheCreateTextureFromImage,
              (kCFAllocatorDefault,
               _texWriteCache,
               destPixelBuffer, nil, GL_TEXTURE_2D, GL_RGBA,
               CVPixelBufferGetWidth(destPixelBuffer),
               CVPixelBufferGetHeight(destPixelBuffer),
               GL_BGRA, GL_UNSIGNED_BYTE,  0,
               &destTexture))
    
    // offscreen ---------------------------------------
    
    glViewport(0, 0, _offscreendimensions.width, _offscreendimensions.height);
    glUseProgram(_shaderNow.program);
    
    /* GL_TEXTURE2 works but GL_TEXTURE5 does not
     * perhaps because is was already bound to a uniform?
     */
    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenBuffer);
    glActiveTexture(GL_TEXTURE5); // same as GL_TEXTURE4 below
    glBindTexture(CVOpenGLESTextureGetTarget(destTexture), CVOpenGLESTextureGetName(destTexture));
	GLTx2DEdge(LINEAR)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, CVOpenGLESTextureGetTarget(destTexture), CVOpenGLESTextureGetName(destTexture), 0);
    
    [_shaderNow drawVertex:_vertex pixType:kDrawPixWrite mirror:mirror];
	
    glFinish();
    
    glBindTexture(CVOpenGLESTextureGetTarget(srcTexture), 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    // onscreen -------------------------------------
    
    static CGSize screenSize = UIScreen.mainScreen.fixedCoordinateSpace.bounds.size;
    glViewport(0, 0, screenSize.width, screenSize.height);
    
    glUseProgram(_shaderPass.program);  // passthrough ----------------------
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glActiveTexture(GL_TEXTURE5); // same as GL_TEXTURE4  above
	glBindTexture(CVOpenGLESTextureGetTarget(destTexture), CVOpenGLESTextureGetName(destTexture));
    
    [_shaderPass drawVertex:_vertex pixType:kDrawPixThru mirror:NO];
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_glContext presentRenderbuffer:GL_RENDERBUFFER];
    glBindTexture(CVOpenGLESTextureGetTarget(destTexture), 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
bail:  // cleanup -------------------------
    
    [_shaderNow flush];
    
    if (err) {
        
        NSError* error = [NSError errorWithDomain:@"Venus Pearl" code:err userInfo:nil];
        completionBlock(nil, error);
    }
    else {
        completionBlock(destPixelBuffer,nil);
    }
    if (destTexture) {
        
        CVOpenGLESTextureCacheFlush(_texWriteCache, 0);
        CFRelease(destTexture);
    }
    if (destPixelBuffer) {
        
        CVPixelBufferRelease(destPixelBuffer);
    }
    displaying = NO;
}

@end
