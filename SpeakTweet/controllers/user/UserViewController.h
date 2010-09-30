#import <UIKit/UIKit.h>
#import "TwitterUserClient.h"
#import "Message.h"

@interface UserViewController : UITableViewController 
	<UITableViewDelegate, UITableViewDataSource, TwitterUserClientDelegate> {
	Message *message;
	User *userInfo;
}

@property(readwrite, retain) Message *message;

@end
