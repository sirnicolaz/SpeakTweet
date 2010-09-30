#import "UserCell.h"
#import "Colors.h"

@interface UserCell(Private)
- (void)createCell;

@end


@implementation UserCell

@synthesize user;

- (id)initWithFrame:(CGRect)rect reuseIdentifier:(NSString*)anId {
	if (self = [super initWithFrame:rect reuseIdentifier:anId]) {
		[self createCell];
	}
	return self;
}

- (void)dealloc {
	[user release];
	[iconView release];
	[super dealloc];
}

- (void)createCell {
	iconView = [[RoundedIconView alloc] 
				 initWithFrame:CGRectMake(7.0, 7.0, 30.0, 30.0) 
				 image:[IconRepository defaultIcon]
				 round:5.0];
	[self.contentView addSubview:iconView];	
}

- (void)updateByUser:(User*)anUser isEven:(BOOL)even{
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.cellType = CellTypeNoRound;
	
	isEven = even;
	
	[user release];
	user = [anUser retain];
	[self updateIcon];
	[self setNeedsDisplay];
}


+ (void)drawText:(NSString*)text selected:(BOOL)selected {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	if (selected) {
		CGContextSetFillColorWithColor(context, [[Colors instance] textSelected].CGColor);
	} else {
		CGContextSetFillColorWithColor(context, [[Colors instance] textForground].CGColor);
		[[Colors instance] textShadowBegin:context];
	}
	
	[text drawInRect:CGRectMake(13+30, 10, 280-30, 24)
			withFont:[UIFont boldSystemFontOfSize:18]
	   lineBreakMode:UILineBreakModeTailTruncation];
		
	[[Colors instance] textShadowEnd:context];
}	

- (void)drawRect:(CGRect)rect {
	
	if (isEven) {
		bgcolor = [[Colors instance] evenBackground];
	} else {
		bgcolor = [[Colors instance] oddBackground];
	}
	
	[super drawRect:rect];
	[UserCell drawText:[NSString stringWithFormat:@"%@ / %@",user.screen_name,user.name] 
				  selected:NO];
}

- (void)drawBackgroundRect:(CGRect)rect {
	[super drawBackgroundRect:rect];
	[UserCell drawText:[NSString stringWithFormat:@"%@ / %@",user.screen_name,user.name] 
				  selected:YES];
}

- (void)updateIcon {
	UIImage *icon = user.iconContainer.iconImage;
	if (icon == nil) {
		icon = [IconRepository defaultIcon];
	}
	[iconView setImage:icon];
}

@end
