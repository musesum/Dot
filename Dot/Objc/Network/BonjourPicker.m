

#import "BonjourPicker.h"

#define kOffset 5.0

@implementation BonjourPicker

- (id)initWithFrame:(CGRect)frame type:(NSString*)type {
    
	if ((self = [super initWithFrame:CGRectMake((frame.size.width-320)/2, (frame.size.height-480)/2, 320, 480)])) {
		self.bvc = [BrowserVC.alloc initWithTitle:nil showDisclosureIndicators:NO showCancelButton:NO];
		[self.bvc searchForServicesOfType:type inDomain:@"local"];
    
		self.opaque = YES;
		self.backgroundColor = [UIColor blackColor];
        self.userInteractionEnabled=YES;
        
		UIImageView* img = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"bg.png"]];
		[self addSubview:img];
		
		CGFloat runningY = kOffset;
		CGFloat width = self.bounds.size.width - 2 * kOffset;
		
		UILabel* label = [UILabel.alloc initWithFrame:CGRectZero];
		[label setTextAlignment:UITextAlignmentCenter];
		[label setFont:[UIFont boldSystemFontOfSize:15.0]];
		[label setTextColor:[UIColor whiteColor]];
		[label setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
		[label setShadowOffset:CGSizeMake(1,1)];
		[label setBackgroundColor:[UIColor clearColor]];
		label.text = @"Publishing as:";
		label.numberOfLines = 1;
		[label sizeToFit];
		label.frame = CGRectMake(kOffset, runningY, width, label.frame.size.height);
		[self addSubview:label];
		
		runningY += label.bounds.size.height;
		
		self.gameNameLabel = [UILabel.alloc initWithFrame:CGRectZero];
		[self.gameNameLabel setTextAlignment:UITextAlignmentCenter];
		[self.gameNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:24]];
		[self.gameNameLabel setLineBreakMode:UILineBreakModeTailTruncation];
		[self.gameNameLabel setTextColor:[UIColor whiteColor]];
		[self.gameNameLabel setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
		[self.gameNameLabel setShadowOffset:CGSizeMake(1,1)];
		[self.gameNameLabel setBackgroundColor:[UIColor clearColor]];
		[self.gameNameLabel setText:@"Default Name"];
		[self.gameNameLabel sizeToFit];
		[self.gameNameLabel setFrame:CGRectMake(kOffset, runningY, width, self.gameNameLabel.frame.size.height)];
		[self.gameNameLabel setText:@""];
		[self addSubview:self.gameNameLabel];
        
		runningY += self.gameNameLabel.bounds.size.height + kOffset * 2;
		
		label = [UILabel.alloc initWithFrame:CGRectZero];
		[label setTextAlignment:UITextAlignmentCenter];
		[label setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
		[label setTextColor:[UIColor whiteColor]];
		[label setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
		[label setShadowOffset:CGSizeMake(1,1)];
		[label setBackgroundColor:[UIColor clearColor]];
		label.text = @"Or select to subscribe to:";
		label.numberOfLines = 1;
		[label sizeToFit];
		label.frame = CGRectMake(kOffset, runningY, width, label.frame.size.height);
		[self addSubview:label];
        
        runningY += label.bounds.size.height + 12; 
        
        CGSize buttonSize = CGSizeMake(120, 32);
        CGSize bLabelSize = CGSizeMake(80, 14);
        
        CGRect popFrame = CGRectMake(0,0, 320, 480);
        CGRect bvcFrame = CGRectMake(popFrame.origin.x, runningY, popFrame.size.width, popFrame.size.height - runningY - buttonSize.height-8);
        [self.bvc.view setFrame:bvcFrame];
        
        _buttonLabel = [UILabel.alloc init];
        _buttonLabel.frame           = CGRectMake((buttonSize.width-bLabelSize.width)/2,
                                                  (buttonSize.height-bLabelSize.height)/2,
                                                  bLabelSize.width,bLabelSize.height);
        _buttonLabel.backgroundColor = [UIColor clearColor];
        _buttonLabel.textColor       = [UIColor grayColor];
        _buttonLabel.shadowColor     = [UIColor blackColor];
        _buttonLabel.shadowOffset    = CGSizeMake(1,1);
        _buttonLabel.textAlignment   = UITextAlignmentCenter;
        _buttonLabel.text            = @"Go Solo";
        _buttonLabel.font             =[UIFont fontWithName:@"HelveticaNeue" size:15];

        _button =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_button setImage:[UIImage imageNamed:@"RoadButton.png"] forState:UIControlStateNormal];
        _button.frame = CGRectMake((self.frame.size.width-buttonSize.width)/2,self.frame.size.height-buttonSize.height-4,buttonSize.width,buttonSize.height); 
        _button.userInteractionEnabled = YES;
        [_button addTarget:self action:@selector(cancelled) forControlEvents:UIControlEventTouchUpInside];
        [_button addSubview:_buttonLabel];
        [self addSubview:_button];

        [self addSubview:self.bvc.view];
		
	}
    
	return self;
}

- (void)cancelled {

    [self removeFromSuperview];
}

- (NSString*)gameName {
	return self.gameNameLabel.text;
}

- (void)setGameName:(NSString*)string {
	[self.gameNameLabel setText:string];
	[self.bvc setOwnName:string];
}

@end
