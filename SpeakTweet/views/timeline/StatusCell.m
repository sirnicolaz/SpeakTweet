#import "StatusCell.h"
#import "Colors.h"
#import "IconRepository.h"
#import "AppDelegate.h"
#import "TweetPostViewController.h"
#import "Configuration.h"
#import "CellBackgroundView.h"
#import "Images.h"
#import "SelectedCellBackgroundView.h"
#import "TwitterPost.h"
#import "NSDateExtended.h"

@implementation StatusCell

@synthesize status;

+ (UIFont*)textFont {
	return [UIFont systemFontOfSize:14.0];
}

+ (UIFont*)metaFont {
	return [UIFont boldSystemFontOfSize:11.0];
}

+ (CGFloat)getTextboxHeight:(NSString *)str {
    UILabel *textLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    textLabel.font = [StatusCell textFont];
    textLabel.numberOfLines = 10;
    textLabel.text = str;
    CGRect bounds = CGRectMake(0, 0, 256, 300.0);
    CGRect result = [textLabel textRectForBounds:bounds limitedToNumberOfLines:10];
	CGFloat h = result.size.height;
	[textLabel release];
	return h;
}

+ (void)drawTexts:(Status*)status selected:(BOOL)selected{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat metaTextY = status.cellHeight - 17;
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	if (selected) {
		CGContextSetFillColorWithColor(context, [[Colors instance] textSelected].CGColor);
	} else {
		CGContextSetFillColorWithColor(context, [[Colors instance] textForground].CGColor);
	}
	
	[status.message.text drawInRect:CGRectMake(48.0, 4.0, 256, status.textHeight) 
	 withFont:[StatusCell textFont]
	 lineBreakMode:UILineBreakModeWordWrap];
	
	if (selected) {
		CGContextSetFillColorWithColor(context, [[Colors instance] textSelected].CGColor);
	} else {
		CGContextSetFillColorWithColor(context, [[Colors instance] textAnnotateForground].CGColor);
		[[Colors instance] textShadowBegin:context];
	}
	
	NSString *name;
	if ([status.message.screenName isEqualToString:status.message.name]) {
		name = status.message.screenName;
	} else {
		name = [status.message.screenName stringByAppendingString:@" / "];
		name = [name stringByAppendingString:status.message.name];
	}
	
	[name drawInRect:CGRectMake(48.0, metaTextY, 200.0, 12.0) 
			withFont:[StatusCell metaFont]
	   lineBreakMode:UILineBreakModeTailTruncation];
		
	[[status.message.timestamp descriptionWithStyle] 
				   drawInRect:CGRectMake(264.0, metaTextY, 100.0, 12.0) 
					 withFont:[StatusCell metaFont]
				lineBreakMode:UILineBreakModeTailTruncation];

	if (!selected) {
		[[Colors instance] textShadowEnd:context];
	}
}

- (UIColor*)colorForBackground {
	UIColor *color = nil;
	if (status && !disableColorize) {
		switch (status.message.replyType) {
			case _MESSAGE_REPLY_TYPE_REPLY:
				color = [[Colors instance] replyBackground];
				break;
			case _MESSAGE_REPLY_TYPE_REPLY_PROBABLE:
				color =  [[Colors instance] probableReplyBackground];
				break;
			case _MESSAGE_REPLY_TYPE_DIRECT:
				color =  [[Colors instance] directMessageBackground];
				break;
		}	
	}
	
	if (!color) {
		if (isEven) {
			color = [[Colors instance] evenBackground];
		} else {
			color = [[Colors instance] oddBackground];
		}
	}
	return color;
}

- (void)createCell {
	iconView = [[[RoundedIconView alloc] 
				 initWithFrame:CGRectMake(4.0, 6.0, 40.0, 40.0) 
				 image:[IconRepository defaultIcon]
				 round:5.0] autorelease];
	[self.contentView addSubview:iconView];	

	unreadView = [[[UIImageView alloc] initWithFrame:CGRectMake(300, 0, 16, 16)] autorelease];
	unreadView.hidden = YES;
	[self.contentView addSubview:unreadView];

	self.accessoryType = UITableViewCellAccessoryNone;
	
	SelectedCellBackgroundView *v = [[[SelectedCellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
	v.status = status;
	self.selectedBackgroundView = v;
}

- (id)initWithIsEven:(BOOL)iseven {
	self = [super initWithFrame:CGRectZero reuseIdentifier:CELL_RESUSE_ID];
	isEven = iseven;
	[self createCell];
	return self;
}

- (void)dealloc {
	[status release];
	[super dealloc];
}

- (void)updateBackgroundColor {
	UIColor *color = [self colorForBackground];
	((CellBackgroundView*)self.backgroundView).backgroundColor = color;
	iconView.backgroundColor = color;
	
	if (status.message.status == _MESSAGE_STATUS_NORMAL) {
		unreadView.hidden = NO;
	} else {
		unreadView.hidden = YES;
	}
}

- (void)iconButtonPushed:(id)sender {
	LOG(@"reply to @%@", status.message.screenName);
	
	if (status.message.replyType == _MESSAGE_REPLY_TYPE_DIRECT) {
		[[TwitterPost shardInstance] createDMPost:status.message.screenName withReplyMessage:status.message];
	} else {
		[[TwitterPost shardInstance] createReplyPost:[@"@" stringByAppendingString:status.message.screenName]
										withReplyMessage:status.message];
	}
}

- (void)updateCell:(Status*)aStatus isEven:(BOOL)iseven {
	
	[status release];
	status = aStatus;
	[status retain];
	
	isEven = iseven;
	
	if (status.message.favorited) {
		CGRect r = CGRectMake(300, (status.cellHeight-16)/2, 16, 16);
		if (starView == nil) {
			starView = [[UIImageView alloc] initWithFrame:r];
			starView.image = [[Images sharedInstance] starHilighted];
			[self.contentView addSubview:starView];
		} else {
			[starView setFrame:r];
		}
	} else if (starView) {
		[starView removeFromSuperview];
		[starView release];
		starView = nil;
	}
	
	unreadView.frame = CGRectMake(302, 2, 16, 16);
	
	if ([[Configuration instance] darkColorTheme]) {
		unreadView.image = [[Images sharedInstance] unreadDark];
	} else {
		unreadView.image = [[Images sharedInstance] unreadLight];
	}

	UIImage *icon = status.message.iconContainer.iconImage;
	if (icon == nil) {
		icon = [IconRepository defaultIcon];
	}
	[iconView setImage:icon];
	
	[iconView addTarget:self 
				 action:@selector(iconButtonPushed:)
	   forControlEvents:UIControlEventTouchUpInside];
	
	[self updateBackgroundColor];
	[self setNeedsDisplay];
	
	((SelectedCellBackgroundView*)self.selectedBackgroundView).status = status;
	[(SelectedCellBackgroundView*)self.selectedBackgroundView setNeedsDisplay];
}

- (void)updateIcon {
	[iconView setImage:status.message.iconContainer.iconImage];
}

- (void)drawRect:(CGRect)rect {
//	[CellBackgroundView drawBackground:rect gradient:[[Colors instance] timelineBackgroundGradient]];
	[CellBackgroundView drawBackground:rect backgroundColor:[self colorForBackground]];
	[StatusCell drawTexts:status selected:NO];
}

- (void)setDisableColorize {
	disableColorize = YES;
}


@end