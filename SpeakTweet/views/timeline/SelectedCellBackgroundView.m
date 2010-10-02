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
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawLinearGradient(context, [[Colors instance] timelineSelectedBackgroundGradient], 
								CGPointMake(0,0), CGPointMake(0,rect.size.height), 
								kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);

	[StatusCell drawTexts:status selected:YES];
}

- (void)dealloc {
	[status release];
	[super dealloc];
}

@end
