#import "LinkTweetCell.h"
#import "Colors.h"
#import "CellBackgroundView.h"

@implementation LinkTweetCell

+ (void)drawText:(NSString*)text footer:(NSString*)footer textHeight:(CGFloat)textHeight selected:(BOOL)selected{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	if (selected) {
		CGContextSetFillColorWithColor(context, [[Colors instance] textSelected].CGColor);
	} else {
		CGContextSetFillColorWithColor(context, [[Colors instance] textForground].CGColor);
		[[Colors instance] textShadowBegin:context];
	}

	[text drawInRect:CGRectMake(13, 13, 300, textHeight)
			withFont:[UIFont systemFontOfSize:16]
	   lineBreakMode:UILineBreakModeTailTruncation];

	[footer drawInRect:CGRectMake(13, 17 + textHeight, 300, 12)
			withFont:[UIFont boldSystemFontOfSize:11]
	   lineBreakMode:UILineBreakModeTailTruncation];

	[[Colors instance] textShadowEnd:context];
}

- (void)dealloc {
	[text release];
	[footer release];
    [super dealloc];
}

- (void)createCellWithText:(NSString*)aText footer:(NSString*)aFooter textHeight:(CGFloat)aTextHeight {
	self.cellType = CellTypeRoundSpeech;
	text = [aText retain];
	footer = [aFooter retain];
	textHeight = aTextHeight;
	bgcolor = [[Colors instance] oddBackground];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[LinkTweetCell drawText:text footer:footer textHeight:textHeight selected:NO];
}

- (void)drawSelectedBackgroundRect:(CGRect)rect {
	[super drawSelectedBackgroundRect:rect];
	[LinkTweetCell drawText:text footer:footer textHeight:textHeight selected:YES];
}

@end

@implementation LinkNameCell

+ (void)drawName:(NSString*)name screenName:(NSString*)screenName selected:(BOOL)selected {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	if (selected) {
		CGContextSetFillColorWithColor(context, [[Colors instance] textSelected].CGColor);
	} else {
		CGContextSetFillColorWithColor(context, [[Colors instance] textForground].CGColor);
		[[Colors instance] textShadowBegin:context];
	}

	[name drawInRect:CGRectMake(70.0, 10.0, 230.0, 30.0)
			withFont:[UIFont boldSystemFontOfSize:20.0]
	   lineBreakMode:UILineBreakModeTailTruncation];

	[screenName drawInRect:CGRectMake(70.0, 30+6.0, 230.0, 30.0)
			withFont:[UIFont boldSystemFontOfSize:14.0]
	   lineBreakMode:UILineBreakModeTailTruncation];

	[[Colors instance] textShadowEnd:context];
}

- (void)dealloc {
	[name release];
	[screenName release];
    [super dealloc];
}

- (void)createCellWithName:(NSString*)aName screenName:(NSString*)aScreenName {
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.cellType = CellTypeRound;
	name = [aName retain];
	screenName = [aScreenName retain];
	bgcolor = [[Colors instance] oddBackground];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[LinkNameCell drawName:name screenName:screenName selected:NO];
}

- (void)drawBackgroundRect:(CGRect)rect {
	[super drawBackgroundRect:rect];
	[LinkNameCell drawName:name screenName:screenName selected:YES];
}

@end



