
#import "ThumbXY.h"
#import "MuDrawCircle.h"
#import "CallIdSel.h"
#import "Tr3.h"
#import "SkyTr3Root.h"
#import "Tr3Cache.h"
#import "SkyDefs.h"
#import "Tr3Objc.h"
#import "UIExtras.h"

#define PrintThumbBase(...) DebugPrint(__VA_ARGS__)
#define LoopTime (1.0/60.0)

@implementation ThumbBase

- (id)initWithTr3:(Tr3*)tr3 {
    
    _title = [NSString stringWithUTF8String:tr3->name.c_str()];
    _frame = CGRectZero;
    _startVal = CGPointMake(.5,.5);
    _tap2Val = CGPointMake(-1,-1);
    _lag = 0;
    _radius = 0;
    _iconNameOff = nil;
    _iconNameOn = @"dot.pearl.white.png";

    for (Tr3*child : tr3->children) {
        
        switch (str2int(child->name.c_str())) {
                
            case str2int("title"):  _title = [NSString stringWithUTF8String:(char*)*child]; break;
            case str2int("frame"):  _frame   = Tr3Rect(child); break;
            case str2int("tap2"):   _tap2Val = Tr3Point(child); break;
            case str2int("lag"):    _lag     = (float)*child; break;
            case str2int("radius"): _radius  = (float)*child; break;
                
            case str2int("value"): {
                
                _tr3Value = child;
                _startVal = Tr3Point(_tr3Value);
                
                if (_tr3Value->val) {
                     _tr3Value->addCall ((Tr3CallTo)(&Tr3ThumbValue),(void*)new CallIdSel(self));
                }
                break;
            }
            case str2int("master"): {
                
                _tr3Master = child;
                _tr3Master->addCall((Tr3CallTo)(&Tr3ThumbMaster),(void*)new CallIdSel(self));
                break;
            }
            case str2int("default"): {
                
                _tr3Default = child;
                _tr3Default->addCall((Tr3CallTo)(&Tr3ThumbDefault),(void*)new CallIdSel(self));
                break;
            }
            case str2int("icon"): {
                
                if (child->val) {
                    
                    if (child->val->flags.tupple) {
                        Tr3ValTupple& vt = (Tr3ValTupple&)*child->val;
                        if (vt.vals.size()>0 && vt.vals[0]->flags.quote) {
                            Tr3ValQuote& vtq = (Tr3ValQuote&)*vt.vals[0];
                            _iconNameOff = [NSString stringWithUTF8String:(char*)vtq.quote.c_str()];
                        }
                        if (vt.vals.size()>1 && vt.vals[1]->flags.quote) {
                            Tr3ValQuote& vtq = (Tr3ValQuote&)*vt.vals[1];
                            _iconNameOn = [NSString stringWithUTF8String:(char*)vtq.quote.c_str()];
                        }
                    }
                    else if (child->val->flags.quote) {
                        Tr3ValQuote& vq = (Tr3ValQuote&)*child->val;
                        _iconNameOn = [NSString stringWithUTF8String:(char*)vq.quote.c_str()];
                    }
                }
                break;
            }

        }
    }
    self = [super initWithFrame:_frame];
    [self updateBase];
    [self updateSub];
    [self updateCursor];
    return self;
}

- (void) updateBase {
    
    self.animating = false;
    _tap2ing = NO;
    
    _iconOff = _iconNameOff ? [UIImage getIconPath:"/tr3/dot/png" name:_iconNameOff.UTF8String] : nil;
    _iconOn  = _iconNameOn  ? [UIImage getIconPath:"/tr3/dot/png" name:_iconNameOn.UTF8String] : nil;
    
    CGFloat w = _frame.size.width;
    CGFloat h = _frame.size.height;
    CGFloat b = 2;   // border
    
    _radius = _radius == 0 ? h/2 - b : _radius ; // radius
    _minXY = CGPointMake(    _radius + b,     _radius + b);
    _maxXY = CGPointMake(w - _radius - b, h - _radius - b);
    _range = CGPointMake(_maxXY.x - _minXY.x, _maxXY.y - _minXY.y);
    _prevVal = _value;
    _nextVal = _prevVal;
}

- (void) updateSub {
    
    NSLog(@"ThumbBase::updateSub has no override");
}

/* change icon based on whether Tr3Master is master or slave
 * There is always _iconOn, with optional _iconOff
 * if no _iconOff, then use alpha for _iconOn to grey out
 */
- (void)updateMaster {
    
    if (_tr3Master) {
         NSLog(@"ThumbBase::updateMaster has no override");
    }
}

- (void)updateValue {
    
    if (self.animating) {
        return;
    }
    if (_tr3Value && _tr3Value->val) {
        
        if (_tr3Value->val->flags.tupple) {
            Tr3ValTupple* val = (Tr3ValTupple*)_tr3Value->val;
            float vx = *(*_tr3Value)[0];
            float vy = *(*_tr3Value)[1];
            [self setValue: CGPointMake(vx,vy)];
        }
        else if (_tr3Value->val->flags.scalar) {
            Tr3ValScalar* val = (Tr3ValScalar*)_tr3Value->val;
            float vx = val->rangeTo01();
            [self setValue: CGPointMake(vx,vx)];
        }
    }
}
void Tr3ThumbValue(Tr3*from,Tr3CallData*data) {
    
    __block id target = (__bridge id)(data->_instance);
    dispatch_async(dispatch_get_main_queue(), ^{
        [target updateValue];
    });
}
void Tr3ThumbMaster(Tr3*from,Tr3CallData*data) {
    
    __block id target = (__bridge id)(data->_instance);
    dispatch_async(dispatch_get_main_queue(), ^{
        [target updateMaster];
    });
}

void Tr3ThumbDefault(Tr3*from,Tr3CallData*data) {
    
    __block id target = (__bridge id)(data->_instance);
    dispatch_async(dispatch_get_main_queue(), ^{
        [target updateDefault];
    });
}

#pragma mark - position

- (void)updateCursor {
    
    _cursor = CGPointMake(_minXY.x + _value.x * _range.x,
                          _maxXY.y - _value.y * _range.y);
    
    _thumb.center = _cursor;
}


- (void)setValue:(CGPoint)value_ {
    
    if (_value.x != value_.x ||
        _value.y != value_.y) {
        
        _value = value_;
        [self updateCursor];
        
        Floats*fs = new Floats;
        fs->push_back(_value.x);
        fs->push_back(_value.y);
        //PrintThumbBase("\n*** ThumbBase::setValue:(%g,%g)",_value.x,_value.y);
        Tr3Cache::changeRange01(_tr3Value,fs);
    }
}


- (void)animateCursor {

    if (self.animating) {
        return;
    }
    self.animating = true;
    
    CFTimeInterval thisTime = CFAbsoluteTimeGetCurrent();
    double deltaTime = thisTime - _touchTime;
    
    if (deltaTime >= _lag) {
         [self setValue:CGPointMake(_nextVal.x,_nextVal.y)];
        self.animating = false;
        return;
    }
    else {
        CGFloat delta = deltaTime/_lag;
        CGPoint interVal = CGPointMake(_prevVal.x + (_nextVal.x - _prevVal.x) * delta,
                                       _prevVal.y + (_nextVal.y - _prevVal.y) * delta);
        [self setValue:interVal];
    }
    self.animating = false;
    [self performSelector:@selector(animateCursor) withObject:self afterDelay:LoopTime];
 }


- (void)setCursor:(CGPoint)location_ {
    
    _cursor.x = MAX(_minXY.x,MIN(location_.x, _maxXY.x));
    _cursor.y = MAX(_minXY.y,MIN(location_.y, _maxXY.y));
    
    CGPoint remain = CGPointMake(_cursor.x - _minXY.x,
                                 _cursor.y - _minXY.y);
    
    _nextVal = CGPointMake(_range.x ?   remain.x / _range.x : 1,
                           _range.y ? 1-remain.y / _range.y : 1);

    [self animateCursor];
}

/* called from MenuChild
 */
- (void)updateDefault {
    
    [self setCursor: CGPointMake(_minXY.x + _range.x * _startVal.x,
                                 _maxXY.y - _range.y * _startVal.y)];

}

- (void) touchesDoubleTap:(CGPoint)location {
    
    CGFloat x = MAX(_minXY.x,MIN(location.x, _maxXY.x));
    CGFloat y = MAX(_minXY.y,MIN(location.y, _maxXY.y));
    CGFloat dx = _range.x ? x/_range.x : 0;
    CGFloat dy = _range.y ? y/_range.y : 0;
    
    // negative values will allign towards center or edge
    
    if (_tap2Val.x < 0 ) {
        
        CGFloat x2 = roundf(dx * 2) / 2.;
        CGFloat y2 = roundf(dy * 2) / 2.;
        
        [self setCursor: CGPointMake(_minXY.x + _range.x * x2,
                                     _minXY.y + _range.y * y2)];
    }
    else {
        
        [self setCursor: CGPointMake(_minXY.x + _range.x * _tap2Val.x,
                                     _minXY.y + _range.y * _tap2Val.y)];
    }
}

#pragma mark - touches

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {

    if (_tr3Master) {
        _tr3Master->setNow(1);
        [self updateMaster];
    }
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    CFTimeInterval thisTime = CFAbsoluteTimeGetCurrent();
    double deltaTime = thisTime - _touchTime;
    double deltaTime2 = thisTime -_tap2Time;
    _touchTime = thisTime;
    _prevVal = _value;
    
    if (deltaTime < .5) {
        
        [self touchesDoubleTap:location];
        
        _tap2ing = YES;
        _tap2Time = thisTime;
        
    }
    else if (deltaTime2 <.5) {
        ; // don't do do anything for a half second after a double tap
    }
    else {
        _tap2ing = NO;
        [self setCursor:location];
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    
    CFTimeInterval thisTime = CFAbsoluteTimeGetCurrent();
    double deltaTime2 = thisTime - _tap2Time;
    if (_tap2ing || (deltaTime2 <.5)) {
        return;
    }
     _touchTime = thisTime;
    _prevVal = _value;
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView: self];
    [self setCursor:location];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    
    _tap2ing = NO;
}

@end
