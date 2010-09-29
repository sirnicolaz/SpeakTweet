#import "SelectedCellBackgroundView.h"
#import "Colors.h"
#import "CellBackgroundView.h"
#import "StatusCell.h"

@implementation SelectedCellBackgroundView

@synthesize status;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
/*	CGRect r = CGRectMake(0, 12, 320, rect.size.height-24);
	[[UIImage imageNamed:@"timelineBackground_01.png"] drawAtPoint:CGPointMake(0,0)];
	[[UIImage imageNamed:@"timelineBackground_02.png"] drawAsPatternInRect:r];
	[[UIImage imageNamed:@"timelineBackground_03.png"] drawAtPoint:CGPointMake(0,rect.size.height-12)];
*/
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawLinearGradient(context, [[Colors instance] timelineSelectedBackgroundGradient], 
								CGPointMake(0,0), CGPointMake(0,rect.size.height), 
								kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);

//	CGContextRef context = UIGraphicsGetCurrentContext();
//	CGSize shadowPosition = {0,-1};
//	CGContextSetShadowWithColor(context, shadowPosition, 2, [UIColor whiteColor].CGColor);
	[StatusCell drawTexts:status selected:YES];
//	CGContextSetShadowWithColor(context, shadowPosition, 1, NULL);
}

- (void)dealloc {
	[status release];
	[super dealloc];
}

@end
