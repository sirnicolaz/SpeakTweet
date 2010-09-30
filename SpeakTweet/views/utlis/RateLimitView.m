#import "RateLimitView.h"
#import "ShardInstance.h"
#import "RateLimit.h"

@implementation RateLimitView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	int now = [RateLimit shardInstance].rate_limit_remaining;
	int all = [RateLimit shardInstance].rate_limit;

	if (now && all) {
		CGFloat h = rect.size.height * (CGFloat)now / (CGFloat)all;

		CGContextRef context = UIGraphicsGetCurrentContext();
		
		CGContextSetRGBStrokeColor(context, 1.f, 1.f, 1.f, 1.f);
		CGContextSetRGBFillColor(context, 1.f, 1.f, 1.f, 1.f);
		CGContextStrokeRectWithWidth(context, rect, 4);
		CGContextFillRect(context,CGRectMake(0, rect.size.height-h, rect.size.width, h));
	}
}

- (void)dealloc {
    [super dealloc];
}

@end
