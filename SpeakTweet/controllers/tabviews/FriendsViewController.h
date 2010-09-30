#import <UIKit/UIKit.h>

#import "TimelineViewController.h"

@class TweetViewController;
@class MentionsViewController;

@interface FriendsViewController : TimelineViewController <UIActionSheetDelegate>
{		
	UITextField *tweetTextField;
	MentionsViewController *mentionsViewController;
}

@property (readwrite, assign) MentionsViewController *mentionsViewController;

//- (NSMutableArray*)unreadStatuses;
//- (void)allRead;

@end
