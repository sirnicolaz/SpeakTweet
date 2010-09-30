#import "SentsViewController.h"
#import "Account.h"
#import "Configuration.h"
#import "HttpClientPool.h"

@implementation SentsViewController

- (id)init {
	if (self = [super init]) {
		timeline = [[Timeline alloc] initWithDelegate:self 
									  withArchiveFilename:@"sents.plist"];
	}
	return self;
}

- (void)setupNavigationBar {
	[super setupNavigationBar];
	[super setupPostButton];
	[self.navigationItem setTitle:@"Sents"];
}

- (void)timeline:(Timeline*)tl requestForPage:(int)page since_id:(NSString*)since_id {

	

	
	
	TwitterClient *tc = [[HttpClientPool sharedInstance] 
								idleClientWithType:HttpClientPoolClientType_TwitterClient];
	tc.delegate = tl;
	[tc getSentsTimelineWithPage:page since_id:since_id];
}

@end
