#import "IconTextCell.h"
#import "Colors.h"

@implementation IconTextCell


+ (void)drawImage:(UIImage*)image atPoint:(CGPoint)pos withOverlayColor:(UIColor*)color {

	CGContextRef context = UIGraphicsGetCurrentContext();

	CGRect r = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, pos.x, -r.size.height-pos.y);
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, r, image.CGImage);
    
    [color set];
	[[Colors instance] textShadowBegin:context];
    CGContextFillRect(context, r);
	[[Colors instance] textShadowEnd:context];
	
    CGContextRestoreGState(context);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
	CGContextDrawImage(context, r, image.CGImage); // dont shadow with me!
}

+ (void)drawText:(NSString*)text icon:(UIImage*)icon selected:(BOOL)selected{
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

	if (selected) {
		[IconTextCell drawImage:icon 
							atPoint:CGPointMake(13,10) 
				   withOverlayColor:[[Colors instance] selectedIconOverlayColor]];
	} else {
		[IconTextCell drawImage:icon 
							atPoint:CGPointMake(13,10) 
				   withOverlayColor:[[Colors instance] iconOverlayColor]];
	}
	
}	

- (void)createCellWithText:(NSString*)aText icon:(UIImage*)anIcon isEven:(BOOL)even{
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.cellType = CellTypeNoRound;
	
	[text release];
	text = [aText retain];
	
	[icon release];
	icon = [anIcon retain];
	
	isEven = even;
}

- (void)dealloc {
	[text release];
	[icon release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect {
	if (isEven) {
		bgcolor = [[Colors instance] evenBackground];
	} else {
		bgcolor = [[Colors instance] oddBackground];
	}
	
	[super drawRect:rect];
	[IconTextCell drawText:text icon:icon selected:NO];
}

- (void)drawBackgroundRect:(CGRect)rect {
	[super drawBackgroundRect:rect];
	[IconTextCell drawText:text icon:icon selected:YES];
}

@end
