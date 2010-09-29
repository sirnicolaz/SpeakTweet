#import "TimelineViewController.h"

@interface FavoriteViewController : TimelineViewController {
	NSString *screenName;
	NSString *screenNameInternal;
}

- (id)initWithScreenName:(NSString*)screenName;

@end
