
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>

#import <CoreMedia/CoreMedia.h>

#import <MobileCoreServices/MobileCoreServices.h>
#import <OpenGLES/ES2/glext.h>
#import "DeviceCaptureFlags.h"

@protocol VideoSnapshotDelegate <NSObject>
- (void)snapshotDelegateImage:(UIImage*)image;
@end


@interface VideoManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate> {
	
    int _bufsize;
    bool _active;
    id   _snapshotDelegate;
    
    NSURL *_fileURL;
    
    DeviceCaptureFlags          _captureFlags;
    
	AVCaptureConnection         *videoConnection;
    
    CIContext                   *_ciContext;
    CVPixelBufferRef            _outputBuffer;
    dispatch_queue_t            _myQueue;
    
    CVPixelBufferPoolRef        _outputPool;
    CVPixelBufferPoolRef        _outputBufferPool;
    CVOpenGLESTextureCacheRef   _textureCache;
    
    bool _recording;
    
    // ChromeKeySessionManager -------------------
    
	AVCaptureSession   *_captureSession;
    AVCaptureDevice    *_videoDevice;
	id                 _captureSessionObserver;

	NSMutableArray     *_previousSecondTimes;
	float              _videoFrameRate;
	CMVideoDimensions  _videoDimensions;
	CMVideoCodecType   _videoType;
	dispatch_queue_t   _videoCaptureQueue;    
	dispatch_queue_t   _videoProcessingQueue;
    
    BOOL               _adjusting;
    BOOL               _optimize;
    
	BOOL               _writing;
	BOOL               _importing;   	
	BOOL               _writingDidSart;        
    
	AVAssetWriter      *_assetWriter;
	AVAssetWriterInput *_videoWriterInput; 
    AVAssetWriterInput *_audioWriterInput;
    AVCaptureVideoDataOutput *_videoOutput;
    AVCaptureAudioDataOutput *_audioOutput;
    
    CGFloat _torchLevel;

    CMTime _lastAudioCMTime; // for recording drawn frames which has no time stamp
    
    AVAssetWriterInputPixelBufferAdaptor *_pixelBufferAdaptor;
}

+ (id)shared;

@property (nonatomic) int bufsize;
@property (nonatomic) DeviceCaptureFlags captureFlags;
@property (getter=isActive) bool active;
@property (weak) id snapshotDelegate;

@property(strong) NSURL *fileURL;
@property(strong) NSString *resolutionPreset;
@property(readwrite) float videoFrameRate;
@property(nonatomic) CMVideoDimensions videoDimensions;

@property(readwrite) CGFloat torchLevel;
@property(readonly,  getter=isAdjusting) BOOL adjusting;
@property(readwrite, getter=isOptimize) BOOL optimize;
@property(readonly,  getter=isWriting) BOOL writing;
@property(readonly,  getter=isImporting) BOOL importing;

- (bool)addVideoDataOutput;
- (bool)addAudioDataOutput;

- (UIImage*)snapshotImageBuffer:(CVImageBufferRef)imageBuffer;
- (void)startRunning;
- (void)startWritingVideo;
- (void)stopWritingVideo;
- (void)cancelWriting;

- (bool)hasVideoDeviceForPosition:(AVCaptureDevicePosition)captureFlags;
- (AVCaptureDevice*)videoDeviceForPosition:(AVCaptureDevicePosition)captureFlags;
- (AVCaptureDevice*)anyVideoDeviceForPosition:(AVCaptureDevicePosition)captureFlags;
- (bool)addAudioVideoInput:(DeviceCaptureFlags)captureFlags;
- (void)unlockWhiteAndExposureBalanceAtPoint:(CGPoint)point;
- (void)lockWhiteAndExposureBalanceAtPoint:(CGPoint)point;

- (void)renderSample:(CMSampleBufferRef)sampleBuffer
              mirror:(bool)mirror;

@end

//-----------------------------------------------
@interface VideoManager ()

@property(strong) AVCaptureDevice *videoDevice;
@property(readwrite, getter=isAdjusting) BOOL adjusting;
@property(readwrite, getter=isWriting) BOOL writing;
@property(readwrite, getter=isImporting) BOOL importing;

- (void)removeFileURL:(NSURL*)fileURL;
- (BOOL)createAssetWriter;
- (BOOL)assetWriterAppendSampleBuffer:(CMSampleBufferRef)sampleBuffer imageBuffer:(CVImageBufferRef)imageBuffer;

@end


