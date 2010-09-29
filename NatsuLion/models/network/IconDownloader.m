#import "IconDownloader.h"
#import "HttpClientPool.h"

@implementation IconDownloader

@synthesize delegate;

- (void) dealloc {
	LOG(@"IconDownloader#dealloc");
	[delegate release];
	[super dealloc];
}

- (void)download:(NSString*)url {
	[self requestGET:url];
}

- (void)requestSucceeded {
	[delegate iconDownloaderSucceeded:self];
	[[HttpClientPool sharedInstance] releaseClient:self];
}

- (void)requestFailed:(NSError*)error {
	[delegate iconDownloaderFailed:self];
	[[HttpClientPool sharedInstance] releaseClient:self];
}

@end
