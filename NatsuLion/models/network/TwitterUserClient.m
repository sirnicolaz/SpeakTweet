#import "TwitterUserClient.h"
#import "TwitterUserXMLReader.h"
#import "Account.h"
#import "HttpClientPool.h"

@implementation TwitterUserClient

@synthesize delegate;
@synthesize users;

- (void)dealloc {
	[users release];
	[delegate release];
	[super dealloc];
}

- (void)getUserInfo:(NSString*)q {
	NSString *url = [NSString stringWithFormat:@"http://twitter.com/users/show/%@.xml", q];
	[super requestGET:url];
}

- (void)getUserInfoForScreenName:(NSString*)screen_name {
	[self getUserInfo:screen_name];
}

- (void)getUserInfoForUserId:(NSString*)user_id {
	[self getUserInfo:user_id];
}

- (void)getFollowingsWithScreenName:(NSString*)screen_name page:(int)page {
	NSString *url = [NSString stringWithFormat:@"http://twitter.com/statuses/friends/%@.xml", screen_name];
	if (page > 1) {
		url = [NSString stringWithFormat:@"%@?page=%d", url, page];
	}
	[super requestGET:url];
}

- (void)getFollowersWithScreenName:(NSString*)screen_name page:(int)page {
	NSString *url = [NSString stringWithFormat:@"http://twitter.com/statuses/followers/%@.xml", screen_name];
	if (page > 1) {
		url = [NSString stringWithFormat:@"%@?page=%d", url, page];
	}
	[super requestGET:url];
}

- (void)requestSucceeded {
	if (statusCode == 200) {
		if (contentTypeIsXml) {
			TwitterUserXMLReader *xr = [[TwitterUserXMLReader alloc] init];
			[xr parseXMLData:recievedData];
			users = [xr.users retain];
			[xr release];
		}
	}
	
	[delegate twitterUserClientSucceeded:self];
	[[HttpClientPool sharedInstance] releaseClient:self];
}

- (void)requestFailed:(NSError*)error {
	[delegate twitterUserClientFailed:self];
	[[HttpClientPool sharedInstance] releaseClient:self];
}

@end
