#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TwitterClient.h"

@class Message;
@class FriendsViewController;
@class BrowserViewController;
@class TweetPostViewController;
@class UserTimelineViewController;

@interface URLPair : NSObject
{
	NSString *text;
	NSString *url;
	NSString *screenName;
	BOOL conversation;
}

@property(readwrite, retain) NSString *url, *text, *screenName;
@property(readwrite) BOOL conversation;

@end


@interface TweetViewController : UITableViewController 
										<UITableViewDelegate, 
										UITableViewDataSource, 
										TwitterClientDelegate> {											
	Message *message;
	NSMutableArray *links;	
	UIButton *favButton;
	UIActivityIndicatorView *favAI;
}

@property(readwrite, retain) Message *message;

@end

