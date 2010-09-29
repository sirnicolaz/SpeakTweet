#import <UIKit/UIKit.h>
#import "TwitterUserClient.h"
#import "Message.h"

@interface UserListViewController : UITableViewController
	<UITableViewDelegate, UITableViewDataSource, TwitterUserClientDelegate> {
		
	NSArray *users;
	NSString *screenName;
}

@property (readwrite, retain) NSString *screenName;

- (void)iconUpdate:(NSNotification*)sender;

@end
