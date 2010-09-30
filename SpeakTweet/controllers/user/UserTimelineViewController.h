#import <UIKit/UIKit.h>
#import "TimelineViewController.h"

@interface UserTimelineViewController : TimelineViewController {
	NSString *screenName;
	NSArray *screenNames;
}

@property (readwrite, retain) NSString *screenName;
@property (readwrite, retain) NSArray *screenNames;

@end
