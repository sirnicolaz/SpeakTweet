#import "ConversationViewController.h"
#import "HttpClientPool.h"
#import "TwitterPost.h"
#import "Configuration.h"

@implementation ConversationViewController

@synthesize rootMessage;

- (id)init {
	if (self = [super init]) {
		timeline = [[Timeline alloc] initWithDelegate:self 
									  withArchiveFilename:nil];
	}
	return self;
}

- (void)dealloc {
	LOG(@"ConversationViewController#dealloc");
	[rootMessage release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated]; //with reload
	[self.navigationItem setTitle:[NSString stringWithFormat:@"%@ & %@", 
								   rootMessage.screenName,
								   rootMessage.in_reply_to_screen_name]];
	
	Status *rs = [[[Status alloc] initWithMessage:rootMessage] autorelease];
	NSArray *statuses = [NSArray arrayWithObjects:rs, nil];
	[timeline appendStatuses:statuses];

	// for reload view
	[super timeline:timeline clientSucceeded:nil insertedStatuses:statuses];

	NSString *sid = rs.message.in_reply_to_status_id;
	if (sid.length > 0) {
		TwitterClient *tc = [[HttpClientPool sharedInstance] 
									idleClientWithType:HttpClientPoolClientType_TwitterClient];
		tc.delegate = timeline;
		[tc getStatusWithStatusId:sid];
	}

	if (![[Configuration instance] lefthand]) {
		[super setupPostButton];
	}
}

- (void)timeline:(Timeline*)tl clientSucceeded:(TwitterClient*)client insertedStatuses:(NSArray*)statuses {
	[super timeline:tl clientSucceeded:client insertedStatuses:statuses];
	if (statuses.count == 1) {
		Status *lastStatus = [statuses lastObject];
		NSString *sid = lastStatus.message.in_reply_to_status_id;
		if (sid.length > 0) {
			TwitterClient *tc = [[HttpClientPool sharedInstance] 
										idleClientWithType:HttpClientPoolClientType_TwitterClient];
			tc.delegate = tl;
			[tc getStatusWithStatusId:sid];
		}
	}
}

- (void)setupTableView {
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)postButton:(id)sender {
	[[TwitterPost shardInstance] createReplyPost:[@"@" stringByAppendingString:rootMessage.screenName]
									withReplyMessage:rootMessage];
	[super postButton:sender];
}

@end
