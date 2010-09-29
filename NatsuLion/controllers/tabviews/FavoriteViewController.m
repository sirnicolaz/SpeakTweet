#import "FavoriteViewController.h"
#import "Account.h"
#import "Configuration.h"
#import "HttpClientPool.h"

@implementation FavoriteViewController

- (id)initWithScreenName:(NSString*)aScreenName {
	if (self = [self init]) {
		if (aScreenName) {
			screenName = [aScreenName retain];
			timeline = [[Timeline alloc] initWithDelegate:self 
										  withArchiveFilename:nil];
		} else {
			timeline = [[Timeline alloc] initWithDelegate:self 
										  withArchiveFilename:@"favorites.plist"];
		}
	}
	return self;
}

- (void)dealloc {
	LOG(@"FavoriteViewController#dealloc");
	[screenName release];
	[screenNameInternal release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated]; //with reload

	[screenNameInternal release];
	if (screenName == nil) {
		screenNameInternal = [[[Account sharedInstance] screenName] retain];
		[self.navigationItem setTitle:@"Favorites"];
	} else {
		screenNameInternal = [screenName retain];
		[self.navigationItem setTitle:[NSString stringWithFormat:@"%@'s fav", screenNameInternal]];
	}
}

- (void)setupNavigationBar {
	[super setupNavigationBar];
	[super setupPostButton];
}

- (void)timeline:(Timeline*)tl requestForPage:(int)page since_id:(NSString*)since_id {
	TwitterClient *tc = [[HttpClientPool sharedInstance] 
							 idleClientWithType:HttpClientPoolClientType_TwitterClient];
	tc.delegate = tl;
	[tc getFavoriteWithScreenName:screenNameInternal page:page since_id:since_id];
}

@end

