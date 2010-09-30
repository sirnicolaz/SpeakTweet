#import "MentionsViewController.h"
#import "Account.h"
#import "Configuration.h"
#import "Cache.h"
#import "TwitterClient.h"
#import "FriendsViewController.h"
#import "HttpClientPool.h"

@implementation MentionsViewController

@synthesize friendsViewController;

- (id)init {
	if (self = [super init]) {
		timeline = [[Timeline alloc] initWithDelegate:self 
									  withArchiveFilename:@"replies.plist"];
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
	[self.navigationItem setTitle:@"Mentions"];
}

- (void)dealloc {
	[super dealloc];
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
	[tc getRepliesTimelineWithPage:page since_id:since_id];
}

- (void)timeline:(Timeline*)tl clientSucceeded:(TwitterClient*)client insertedStatuses:(NSArray*)statuses {
	[super timeline:tl clientSucceeded:client insertedStatuses:statuses];
//	[friendsViewController.timeline appendStatuses:statuses];
}

@end
