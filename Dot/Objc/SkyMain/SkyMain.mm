
#import "SkyMain.h"
#import "SkyTr3.h"

#import "ScreenView.h"
#import "VideoManager.h"

#define PrintSkyMain(...) // DebugPrint(__VA_ARGS__)

@implementation SkyMain

#pragma mark - init

+(SkyMain*) shared {
    
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [self.alloc init];
    });
    return shared;
}

- (id)init {
    
    self = [super init];
    _skyTr3 = SkyTr3.shared;

    [self initPixelBuffer:_skyTr3.skySize];
    [self initVideoShaderPipeline];
    [self initErasingSound];
    [self initCamera];
    [self initNetwork];
    
    return self;
}

- (void) initErasingSound {
   _erasingSound = [SoundEffect.alloc initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Sounds/Erase" ofType:@"caf"]];
}
- (void) initCamera {
    //[_cameraView pearlRevealState:kRevealHidden center:MenuDock.shared.center];
    //[_cameraView showCameraOverlay];
}
- (void) initNetwork {
    //_appNetworkView = [[AppNetworkView.alloc init];
    //[_appNetworkView setup:_window];
}

- (void)initPixelBuffer:(CGSize)size {
    
    if (_cvPixelBufferRef) {
        
        CVBufferRelease(_cvPixelBufferRef);
        _cvPixelBufferRef = nil;
    }
    NSDictionary *options =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
     [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
     nil];
    
    CVPixelBufferCreate(kCFAllocatorDefault,
                        size.width,
                        size.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef) options,
                        &_cvPixelBufferRef);
}


#pragma mark - Advance Frame

// setup video manager and work loop
- (void)initVideoShaderPipeline {
    
    _videoManager = [VideoManager shared];
    [WorkLink.shared.delegates addObject:self];
    //PrintSkyMain("\n");
    //Tr3Script::PrintTr3(stderr, SkyRoot, PrintFlags(kBindings|kValues));
}
- (void)getNextFrame {
    
    [_skyTr3 checkEraseUniverse];
    CVPixelBufferLockBaseAddress(_cvPixelBufferRef, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(_cvPixelBufferRef);
    _skyTr3.cellMain->goPixelBuffer(pxdata); // pals goPal
    
    CVPixelBufferUnlockBaseAddress(_cvPixelBufferRef, 0);
    
    void* pal = _skyTr3.cellMain->pic.pix.pals.final._rgbArray;
    
    [ScreenView.shared setDrawBuf:_cvPixelBufferRef drawPal:pal];
}

// caller: WorkLink
- (void)NextFrame {
    
    if (_skyTr3.skyActive) {
        [self getNextFrame];
        [_videoManager renderSample:nil mirror:NO];
    }
}


@end
