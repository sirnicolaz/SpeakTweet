#import "TimelineViewController.h"

@interface ConversationViewController : TimelineViewController {
	Message *rootMessage;
}

@property (readwrite, retain) Message *rootMessage;

@end
