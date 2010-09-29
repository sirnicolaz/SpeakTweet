#import "UserTimelineViewController.h"
#import "Account.h"
#import "Configuration.h"
#import "HttpClientPool.h"
#import "TwitterPost.h"

@implementation UserTimelineViewController

@synthesize screenName, screenNames;

- (id)init {
	if (self = [super init]) {
		timeline = [[Timeline alloc] initWithDelegate:self 
									  withArchiveFilename:nil];
	}
	return self;
}

- (void)dealloc {
	LOG(@"UserTimelineViewController#dealloc");
	[screenName release];
	[screenNames release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated]; //with reload
	
	NSString *title = screenName;
	if (title == nil) {
		for (NSString *n in screenNames) { 
			if (title == nil) {
				title = n;
			} else {
				title = [NSString stringWithFormat:@"%@ + %@", title, n];
			}
		}
	}
	
	[self.navigationItem setTitle:title];
	
	if (![[Configuration instance] lefthand]) {
		[super setupPostButton];
	}
}

- (void)timeline:(Timeline*)tl requestForPage:(int)page since_id:(NSString*)since_id {
	if (screenNames) {
		for (NSString *n in screenNames) {
			TwitterClient *tc = [[HttpClientPool sharedInstance] 
									 idleClientWithType:HttpClientPoolClientType_TwitterClient];
			tc.delegate = tl;
			[tc getUserTimelineWithScreenName:n page:page since_id:since_id];
		}
	} else {
		TwitterClient *tc = [[HttpClientPool sharedInstance] 
								 idleClientWithType:HttpClientPoolClientType_TwitterClient];
		tc.delegate = tl;
		[tc getUserTimelineWithScreenName:screenName page:page since_id:since_id];
	}
}

- (void)timeline:(Timeline*)tl clientSucceeded:(TwitterClient*)client insertedStatuses:(NSArray*)statuses {
	[super timeline:tl clientSucceeded:client insertedStatuses:statuses];

	if (screenNames) {
		for (NSString *n in screenNames) { 
			[timeline hilightByScreenName:n];
		}
	}
}

- (void)postButton:(id)sender {
	NSString *txt = nil;
	if (screenName) {
		txt = [@"@" stringByAppendingString:screenName];
	} else if (screenNames.count == 2){
		txt = [NSString stringWithFormat:@"@%@ @%@", 
			 [screenNames objectAtIndex:0],
			 [screenNames objectAtIndex:1]];
	}

	[[TwitterPost shardInstance] createReplyPost:txt withReplyMessage:nil];
	[super postButton:sender];
}

@end

