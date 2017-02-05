#import "MenuChildPulse.h"
#import "MenuChild.h"
#import "MenuDock.h"
#import "Tr3.h"
#import "VideoManager.h"
#import "SkyTr3Recorder.h"
#import "SkyPatch.h"
#import "SkyMain.h"
#import "SkyMain+Patch.h"
#import "OrienteDevice.h"
#import "SkyTr3Root.h"
#import "SkyPatch.h"
#import "CallIdSel.h"

#define LogMenuChildPulse(...) //DebugLog(__VA_ARGS__) 

@implementation MenuChildPulse

@synthesize color = _color;
@synthesize hsv  = _hsv;
@synthesize rgb  = _rgb;

- (id)initWithPatch:(SkyPatch*)patch_ {
    
    
    self = [super initWithImage:[UIImage imageNamed:@"PaletteDiskWhite256"] blur:YES];
    float edge = 3;
    CGSize size = self.frame.size;
    CGRect outerFrame = CGRectMake(0, 0, size.width+2*edge, size.height+2*edge);
    _imageView.frame = CGRectMake(edge, edge, size.width, size.height);
    self.edge = [MuDrawCircle.alloc initWithFrame:outerFrame];
    _edge.width = 3;
    [self insertSubview:_edge aboveSubview:_imageView];
    
    _tr3MainFrame = SkyRoot->Tr3Bind2("main.frame",Tr3MenuPulseFrame);
    
    Tr3*ripple = SkyRoot->bind("pal.ripple");
    _tr3Hue = ripple->bind("hue");
    _tr3Sat = ripple->bind("sat");
    _tr3Val = ripple->bind("val");
    _tr3Dur = ripple->bind("dur");

    _tr3Recorder = new SkyTr3Recorder("recorder");

    _radiusBorder = edge;
    return self;
}
#pragma mark - MenuDock delegate 

void Tr3MenuPulseFrame(Tr3*from,Tr3CallData*data) {
    
    __block id target = (__bridge id)(data->_instance);
    dispatch_async(dispatch_get_main_queue(), ^{
        [target goFrame];
    });
}


- (void)goFrame {
    
    if (_tr3Recorder)
        _tr3Recorder->goRecorder(*_tr3MainFrame);
}


/*TODO: these used to override ChildMenu::selected unselected
 * need a new way to playback() pause() effect, perhaps new controls. 
 */
- (void)selectedWhatever {
    
    if (_tr3Recorder) 
        _tr3Recorder->playback();
}

- (void)unselected {
    
    if (_tr3Recorder) 
        _tr3Recorder->pause();

}
#pragma mark - menuChild overrides

- (void)hideWithCompletion:(CompletionVoid)completion {
    
    if (_tr3Recorder) 
        _tr3Recorder->playback();
    [_waitTimer invalidate];
    [super hideWithCompletion:completion];
}

- (void)showChild {

    if (_tr3Recorder)  {
        _tr3Recorder->erase();
    }
    [super showChild];
}


#pragma mark -  pulse UI palette

-(CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {	
    
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	size_t width = CGImageGetWidth(inImage);
	size_t height = CGImageGetHeight(inImage);
	
	bitmapBytesPerRow   = (width * 4);
	bitmapByteCount     = (bitmapBytesPerRow * height);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
    
	if (colorSpace == NULL) {
		//NSLog(@"Error allocating color space\n");
		return NULL;
	}
	
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL) {
		///NSLog(@""Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	context = CGBitmapContextCreate (bitmapData,
									 width, height, 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst);
	if (context == NULL) {
        
		free (bitmapData);
	}
	CGColorSpaceRelease( colorSpace );	
	return context;
}
- (void)getPixelColorAtLocation:(CGPoint)point {
    
	CGImageRef inImage = _imageView.image.CGImage;
	// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
	CGContextRef cgctx = (CGContextRef)[self createARGBBitmapContextFromImage:inImage];
	if (cgctx == NULL) { return ; /* error */ }
	
    size_t w = CGImageGetWidth(inImage);
	size_t h = CGImageGetHeight(inImage);
	CGRect rect = {{0,0},{(CGFloat)w,(CGFloat)h}};
	
	// Draw the image to the bitmap context. Once we draw, the memory 
	// allocated for the context for rendering will then contain the 
	// raw image data in the specified color space.
	CGContextDrawImage(cgctx, rect, inImage); 
	
	// Now we can get a pointer to the image data associated with the bitmap context.
	unsigned char* data = (unsigned char*) CGBitmapContextGetData (cgctx);
	if (data != NULL) {
		//offset locates the pixel in the data from x,y. 
		//4 for 4 bytes of data per pixel, w is width of one row of data.
		int offset = 4*((w*round(point.y))+round(point.x));
		_rgb.r     = data[offset+1]; 
		_rgb.g     = data[offset+2]; 
		_rgb.b     = data[offset+3]; 
        
        Colors colors;
        _hsv = colors.rgb2hsv(_rgb);
        
		_color.red   = (float) _rgb.r/255.0; 
		_color.green = (float) _rgb.g/255.0; 
		_color.blue  = (float) _rgb.b/255.0; 
        _color.alpha = .3;
        
		LogMenuChildPulse(@"%s point(%.f,%.f)  rgb(%i %i %i) hsv(%i %i %i)",_cmd,point.x, point.y, _rgb.r,_rgb.g,_rgb.b,_hsv.h,_hsv.s,_hsv.v);
	}
	CGContextRelease(cgctx); 
	if (data) { free(data); }
}
- (CGPoint)constrictCursor:(CGPoint)point_ {
    
    // x,y coordinates for _imageView center is (_radius, _radius)
    CGPoint delta = CGPointMake(point_.x-_radius, point_.y-_radius);
    float radius = sqrt(delta.x*delta.x + delta.y*delta.y);
    
    CGPoint point;
    if (round(radius) > (_radius-_radiusBorder)) {
        
        CGPoint signs       = CGPointMake((int)delta.x/abs((int)delta.x), (int)delta.y/abs((int)delta.y));
        float angle         = atan2f(abs((int)delta.y),abs((int)delta.x));
        CGPoint constrained = CGPointMake((_radius-_radiusBorder)*cos(angle),(_radius-_radiusBorder)*sin(angle));
        CGPoint newDelta    = CGPointMake(constrained.x*signs.x, constrained.y*signs.y);
        point = CGPointMake(_radius+newDelta.x, _radius+newDelta.y);
    }
    else {
        point = point_;
    }
    return point;
}
#pragma mark - pulse

- (void)pulseUpdate {
    
    _tr3Sat->setNow(_hsv.s);
    _tr3Val->setNow(_hsv.v);
    _tr3Hue->setNow(_hsv.h);
}

- (CGPoint)constrict:(CGPoint)point_ {
    
    CGPoint point = [self constrictCursor:point_];
    double thisTime = [NSDate timeIntervalSinceReferenceDate];
    double deltaTime = thisTime - _lastTime;
    
    if (deltaTime > (float)*_tr3Dur) {
        
        _lastTime = thisTime;
        [self getPixelColorAtLocation:point];
        [self pulseUpdate];
        [_edge setColor:self.color];
        [_edge setNeedsDisplay];
    }
    return point;
}


- (void)reScale:(CGFloat)scale_ {
    
    _scale = scale_;
    _radius = _menuSize.width*_scale/2;
    
    float radians = [OrienteDevice shared].deviceRadians;
    [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, _scale, _scale)];
    
    if(_menuParent && _showState==kHidden) {
        
        self.hidden = NO;
    }
}

- (void)hideAfterWait {
    
    [_waitTimer invalidate];
    
    if (_showState == kShowing ||
        _showState == kAnimateToShow) {
        
        _waitTimer = [NSTimer timerWithTimeInterval:2.0
                                             target:self
                                           selector:@selector(hideNow)
                                           userInfo:nil
                                            repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_waitTimer forMode:NSRunLoopCommonModes];
    }
}

#pragma mark - touches

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    _lastTime = 0; //[NSDate timeIntervalSinceReferenceDate];
    [_waitTimer invalidate];
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{_imageView.alpha = .3;} completion:nil];
    if (_tr3Recorder) 
        _tr3Recorder->record();

    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    
    [super touchesEnded:touches withEvent:event];
    [self hideAfterWait];
}

#pragma mark - Menu Parent Dock

- (void)MenuParentSingleTap {
    
    NSString* patchName = _menuParent.patchName;
    SkyPatch* patch = [SkyPatch readPatchName:patchName withUniverse:NO];
    SkyMain* skyMain = [SkyMain shared];
    [skyMain parseTr3:patch.tr3Buf]; ///TODO: set to original value or adjusted value?
    [skyMain parsePatch:patch];
}

- (void)MenuParentDoubleTap {
    
}

@end
