#import "TwitterClient.h"
#import "Account.h"
#import "XMLHTTPEncoder.h"
#import "Configuration.h"
#import "Alert.h"
#import "RateLimit.h"
#import "NSDateExtended.h"
#import "TwitterXMLParser.h"
#import "HttpClientPool.h"

@implementation TwitterClient

@synthesize requestPage, requestForDirectMessage;
@synthesize delegate;

/// private methods

+ (NSString*)URLForTwitterWithAccount {
	return @"http://twitter.com/";
}

- (void)getTimeline:(NSString*)path page:(int)page count:(int)count since_id:(NSString*)since_id {
	NSString* url = [NSString stringWithFormat:@"%@%@.xml?count=%d", 
					 [TwitterClient URLForTwitterWithAccount], path, count];
		
	if (page >= 2) {
		url = [NSString stringWithFormat:@"%@&page=%d&max_id=%@", url, page, since_id];
	} else if (since_id) {
		url = [NSString stringWithFormat:@"%@&since_id=%@", url, since_id];
	}
	
	requestPage = page;
	parseResultXML = YES;
	requestForTimeline = YES;
	
#ifdef ENABLE_OAUTH
	[super requestGET:url];
#else	
	NSString *username = [[Account sharedInstance] screenName];
	NSString *password = [[Account sharedInstance] password];
	
	[super requestGET:url username:username password:password];
#endif	

	[delegate twitterClientBegin:self];
}

- (void) dealloc {
	[delegate release];
	[screenNameForUserTimeline release];
	[super dealloc];
}

- (void)reset {
	[super reset];
	[xmlParser release];
	xmlParser = [[TwitterXMLParser alloc] init];
}

- (void)connection:(NSURLConnection *)c didReceiveResponse:(NSURLResponse *)response {
	[super connection:c didReceiveResponse:response];

	if (rate_limit) {
		[RateLimit shardInstance].rate_limit = rate_limit;
		[RateLimit shardInstance].rate_limit_remaining = rate_limit_remaining;
		[RateLimit shardInstance].rate_limit_reset = rate_limit_reset;
	}
}

- (void)connection:(NSURLConnection *)c didReceiveData:(NSData *)data {
	// don't use recievedData
	if (statusCode == 200 && parseResultXML && contentTypeIsXml) {
		[xmlParser parseXMLDataPartial:data];
	}
}

- (void)requestSucceeded {

	if (statusCode == 200) {
		if (parseResultXML) {
			if (contentTypeIsXml) {		

				// finish parsing
				[xmlParser parseXMLDataPartial:nil];
				if (xmlParser.messages.count > 0) {
					[delegate twitterClientSucceeded:self messages:xmlParser.messages];
				} else {
					[delegate twitterClientSucceeded:self messages:nil];
				}
								
			} else {
				[[Alert instance] alert:@"Invaild XML Format" 
								withMessage:@"Twitter responded invalid format message, or please check your network environment."];
				[delegate twitterClientFailed:self];
			}
		} else {
			[delegate twitterClientSucceeded:self messages:nil];
		}
				
	} else {
		if (statusCode != 304) {
			switch (statusCode) {
				case 400:
					[[Alert instance] alert:@"Twitter: exceeded the rate limit" 
									withMessage:[NSString 
												 stringWithFormat:@"The client has exceeded the rate limit. Clients are allowed %d requests per hour time period. The period will be in %@.", 
												 [RateLimit shardInstance].rate_limit,
												 [[RateLimit shardInstance].rate_limit_reset descriptionWithRateLimitRemaining]]];
					
					break;
				case 401:
				case 403:
					if (screenNameForUserTimeline) {
						[[Alert instance] alert:@"Protected" 
										withMessage:[NSString 
													 stringWithFormat:@"@%@ has protected their updates.", 
													 screenNameForUserTimeline]];
					} else {
						[[Alert instance] alert:@"Authorization Failed" 
										withMessage:@"Wrong Username/Email and password combination."];
					}
					break;
				default:
					{
						NSString *msg = [NSString stringWithFormat:@"Twitter responded %d", statusCode];
						if (requestForTimeline) {
							[[Alert instance] alert:@"Retrieving timeline failed" withMessage:msg];
						} else {
							[[Alert instance] alert:@"Sending a message failed" withMessage:msg];
						}
					}
					break;
			}
		}
		
		[delegate twitterClientFailed:self];
	}
	
	[xmlParser release];
	xmlParser = nil;

	[delegate twitterClientEnd:self];
	[[HttpClientPool sharedInstance] releaseClient:self];
}

- (void)requestFailed:(NSError*)error {
	if (error) {
		[[Alert instance] alert:@"Network error" withMessage:[error localizedDescription]];
	}
	
	[delegate twitterClientFailed:self];
	[delegate twitterClientEnd:self];
	[[HttpClientPool sharedInstance] releaseClient:self];
}

/// public interfaces

- (void)getFriendsTimelineWithPage:(int)page since_id:(NSString*)since_id {
	int count = 20;
	if (since_id == nil && page < 2) {
		count = [[Configuration instance] fetchCount]; 
	} else if (since_id && page < 2) {
		count = 200;
	}
	[self getTimeline:@"statuses/friends_timeline" 
				 page:page 
				count:count
			 since_id:since_id];
}

- (void)getRepliesTimelineWithPage:(int)page since_id:(NSString*)since_id {
	int count = 20;
	if (since_id && page < 2) count = 200;
	[self getTimeline:@"statuses/replies" 
				 page:page 
				count:count 
			 since_id:since_id];
}

- (void)getSentsTimelineWithPage:(int)page since_id:(NSString*)since_id {
	int count = 20;
	if (since_id && page < 2) count = 200;
	[self getTimeline:@"statuses/user_timeline" 
				 page:page 
				count:count 
			 since_id:since_id];
}

- (void)getDirectMessagesWithPage:(int)page since_id:(NSString*)since_id{
	int count = 20;
	if (since_id && page < 2) count = 200;
	requestForDirectMessage = YES;
	[self getTimeline:@"direct_messages" 
				 page:page 
				count:count
			 since_id:since_id];
}

- (void)getSentDirectMessagesWithPage:(int)page {
	requestForDirectMessage = YES;
	[self getTimeline:@"direct_messages/sent" 
				 page:page 
				count:20 
			 since_id:nil];
}

- (void)getUserTimelineWithScreenName:(NSString*)screenName page:(int)page since_id:(NSString*)since_id {
	[screenNameForUserTimeline release];
	screenNameForUserTimeline = screenName;
	[screenNameForUserTimeline retain];
	[self getTimeline:[NSString stringWithFormat:@"statuses/user_timeline/%@", screenName]
				 page:page 
				count:20 
			 since_id:since_id];
}

- (void)getStatusWithStatusId:(NSString*)statusId {
	[self getTimeline:[NSString stringWithFormat:@"statuses/show/%@", statusId]
				 page:1
				count:20 
			 since_id:nil];
}

- (void)post:(NSString*)tweet reply_id:(NSString*)reply_id {
	NSString* url = [NSString stringWithFormat:@"%@statuses/update.xml", 
						[TwitterClient URLForTwitterWithAccount]];
	NSString *postString; 
	if (reply_id == nil) { 
		postString = [NSString stringWithFormat:@"status=%@&source=NatsuLiphone",  
					  [XMLHTTPEncoder encodeHTTP:tweet]]; 
	} else { 
		postString = [NSString stringWithFormat:@"status=%@&in_reply_to_status_id=%@&source=NatsuLiphone",  
					  [XMLHTTPEncoder encodeHTTP:tweet], 
					  reply_id]; 
	}
	
#ifdef ENABLE_OAUTH
	[self requestPOST:url body:postString];
#else	
	NSString *username = [[Account sharedInstance] screenName];
	NSString *password = [[Account sharedInstance] password];
	[self requestPOST:url body:postString username:username password:password];
#endif
}

- (void)createFavoriteWithID:(NSString*)messageId {
	NSString* url = [NSString stringWithFormat:@"%@favorites/create/%@.xml", 
					 [TwitterClient URLForTwitterWithAccount], messageId];
#ifdef ENABLE_OAUTH
	[self requestPOST:url body:nil];
#else	
	NSString *username = [[Account sharedInstance] screenName];
	NSString *password = [[Account sharedInstance] password];
	[self requestPOST:url body:nil username:username password:password];
#endif
}

- (void)destroyFavoriteWithID:(NSString*)messageId {
	NSString* url = [NSString stringWithFormat:@"%@favorites/destroy/%@.xml", 
					 [TwitterClient URLForTwitterWithAccount], messageId];
#ifdef ENABLE_OAUTH
	[self requestPOST:url body:nil];
#else	
	NSString *username = [[Account sharedInstance] screenName];
	NSString *password = [[Account sharedInstance] password];
	[self requestPOST:url body:nil username:username password:password];
#endif
}

- (void)getFavoriteWithScreenName:(NSString*)screenName page:(int)page since_id:(NSString*)since_id{
	[self getTimeline:[NSString stringWithFormat:@"favorites/%@", screenName]
				 page:page 
				count:20 
			 since_id:since_id];
}

@end
