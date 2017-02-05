#import "ScrubView.h"

#define LogScrubView(...)// DebugLog(__VA_ARGS__)
#define PrintScrubView(...) //PrintLog(__VA_ARGS__)

@implementation ScrubView

static id _scrubTarget=nil;

- (id)initWithFrame:(CGRect)frame_
              image:(UIImage*)image_
             update:(CompletionVoid)update_
              reset:(CompletionVoid)reset_
{
 
    self = [super initWithFrame:frame_];

    _update = update_;
    _reset = reset_;
    
    self.imageView = [UIImageView.alloc init];
    _imageView.image = image_;
    _imageView.frame = CGRectMake(0, 0,frame_.size.width, frame_.size.height);
    [self addSubview:_imageView];
    _size = frame_.size;

    self.userInteractionEnabled = YES;
    
    _imageView.layer.cornerRadius = _size.height/2;
    _imageView.clipsToBounds = YES;
    
    return self;
}
- (void)setCursor {
    
    _deltaPoint = CGPointMake(_movePoint.x-_startPoint.x,_movePoint.y-_startPoint.y);
    if (_update)  {
        _update();
    }
}

#pragma mark - touches

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject]; 
    CGPoint location = [touch locationInView:self];
    
    static  CFTimeInterval lastTime =0;
    CFTimeInterval thisTime = CFAbsoluteTimeGetCurrent();
    double deltaEndTime = thisTime - lastTime;
    if (deltaEndTime < .5) {
        if (_reset)  {
            _reset();
        }
    }
    lastTime = thisTime;
    
    _startPoint = CGPointMake(location.x, location.y);
    _movePoint = _startPoint;
    [self setCursor]; // start with a zero delta
    LogScrubView(@"ScrubView::%s _startPoint(%.f,%.f)",_cmd,_startPoint.x,_startPoint.y);
    
}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	
    UITouch* touch = [touches anyObject]; 
    CGPoint location = [touch locationInView:self];
    
    _movePoint = CGPointMake(location.x, location.y);
    LogScrubView(@"ScrubView::%s _movePoint(%.f,%.f)",_cmd,_movePoint.x,_movePoint.y);
    [self setCursor];
    _startPoint = _movePoint;
}
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    
    LogScrubView(@"ScrubView::%s",_cmd);
}

//_____________________________________________________________________________

@end
