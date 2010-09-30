#import <UIKit/UIKit.h>
#import "TimelineViewController.h"

@class FriendsViewController;

@interface MentionsViewController : TimelineViewController {
	FriendsViewController *friendsViewController;
}

@property (readwrite, assign) FriendsViewController *friendsViewController;

@end
