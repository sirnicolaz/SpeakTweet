#import <UIKit/UIKit.h>
#import "TimelineViewController.h"

@class FriendsViewController;
@class MentionsViewController;
@class DirectMessageViewController;

@interface UnreadsViewController : TimelineViewController {
	FriendsViewController *friendsViewController;
	MentionsViewController *replysViewController;
	DirectMessageViewController *directMessageViewController;
}

@property (readwrite, assign) FriendsViewController *friendsViewController;
@property (readwrite, assign) MentionsViewController *replysViewController;
@property (readwrite, assign) DirectMessageViewController *directMessageViewController;

- (void)clearButton:(id)sender;

@end
