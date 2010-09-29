#import "DirectMessageViewController.h"
#import "Account.h"
#import "Configuration.h"
#import "Cache.h"
#import "TwitterClient.h"
#import "HttpClientPool.h"


@implementation DirectMessageViewController

- (id)init {
	if (self = [super init]) {
		timeline = [[Timeline alloc] initWithDelegate:self 
									  withArchiveFilename:@"direct_message.plist"];
		timeline.readTracker = YES;
		timeline.getLatest20TweetOnHumanOperation = YES;
		badge_enable = YES;
		disableColorize = YES;
	}
	return self;
}

- (void)setupNavigationBar {
	[super setupNavigationBar];
	[super setupPostButton];
	[super setupClearButton];
	[self.navigationItem setTitle:@"Direct Messages"];
}

- (void)allRead {
	[timeline markAllAsRead];
	[self.tableView reloadData];
	[self updateBadge];
}

- (void)timeline:(Timeline*)tl requestForPage:(int)page since_id:(NSString*)since_id {
	TwitterClient *tc = [[HttpClientPool sharedInstance] 
							 idleClientWithType:HttpClientPoolClientType_TwitterClient];
	tc.delegate = tl;
	[tc getDirectMessagesWithPage:page since_id:since_id];
}

@end
