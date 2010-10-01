#import "FriendsViewController.h"
#import "TweetViewController.h"
#import "Account.h"
#import "Configuration.h"
#import "AppDelegate.h"
#import "TweetPostViewController.h"
#import "MentionsViewController.h"
#import "HttpClientPool.h"

#define TITLE_NAME @"SpeakTweet"


// ST: for the background image on the navigtion bar
@implementation UINavigationBar (UINavigationBarCategory)

/*- (void)drawRect:(CGRect)rect {
	UIImage *image = [UIImage imageNamed: @"navigation.png"];
	[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}*/
@end
// end ST


@implementation FriendsViewController

@synthesize mentionsViewController;

- (id)init {
	if (self = [super init]) {
		BOOL loadArchive = ! [[Configuration instance] showMoreTweetMode];
		timeline = [[Timeline alloc] initWithDelegate:self 
									  withArchiveFilename:@"friends_timeline.plist"
										  withLoadArchive:loadArchive];
		timeline.readTracker = YES;
		timeline.autoRefresh = YES;
	}
	return self;
}

- (void)setupNavigationBar {
	[super setupNavigationBar];
	[super setupPostButton];
	[super setupClearButton];
	[self.navigationItem setTitle:TITLE_NAME];
}

- (void) dealloc {
    [super dealloc];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (! tweetTextField.editing) {
		[self.navigationItem setTitle:@"Timeline"];
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[self.navigationItem setTitle:TITLE_NAME];
	[super viewWillAppear:animated];
}

- (void)timeline:(Timeline*)tl requestForPage:(int)page since_id:(NSString*)since_id {
	TwitterClient *tc = [[HttpClientPool sharedInstance] 
								idleClientWithType:HttpClientPoolClientType_TwitterClient];
	tc.delegate = tl;
	[tc getFriendsTimelineWithPage:page since_id:since_id];
}

- (void)timeline:(Timeline*)tl clientSucceeded:(TwitterClient*)client insertedStatuses:(NSArray*)statuses {
	[super timeline:tl clientSucceeded:client insertedStatuses:statuses];

	NSMutableArray *replies = [[NSMutableArray alloc] init];
	for (Status *s in statuses) {
		if (s.message.replyType == _MESSAGE_REPLY_TYPE_REPLY || 
			s.message.replyType == _MESSAGE_REPLY_TYPE_REPLY_PROBABLE) {
			[replies addObject:s];
		}
	}
	if (replies.count > 0) {
		[mentionsViewController.timeline appendStatuses:replies];
		[mentionsViewController updateBadge];
	}
	[replies release];
}

- (BOOL)doReadTrack {
	BOOL updated = [super doReadTrack];
	if (updated) {
		[mentionsViewController updateBadge];
	}
	return updated;
}

@end
