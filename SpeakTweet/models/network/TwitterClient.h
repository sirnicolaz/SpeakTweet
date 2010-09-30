#import <UIKit/UIKit.h>
#import "OAuthHttpClient.h"
#import "TwitterXMLParser.h"

@class TwitterClient;

@protocol TwitterClientDelegate
- (void)twitterClientBegin:(TwitterClient*)sender;
- (void)twitterClientEnd:(TwitterClient*)sender;
- (void)twitterClientSucceeded:(TwitterClient*)sender messages:(NSArray*)messages;
- (void)twitterClientFailed:(TwitterClient*)sender;
@end

#ifdef ENABLE_OAUTH
@interface TwitterClient : OAuthHttpClient {
#else
@interface TwitterClient : HttpClient {
#endif
	int requestPage;
	NSString *screenNameForUserTimeline;
	BOOL parseResultXML;
	NSObject<TwitterClientDelegate> *delegate;
	BOOL requestForTimeline;
	BOOL requestForDirectMessage;
	TwitterXMLParser *xmlParser;
}

- (void)getFriendsTimelineWithPage:(int)page since_id:(NSString*)since_id;
- (void)getRepliesTimelineWithPage:(int)page since_id:(NSString*)since_id;
- (void)getSentsTimelineWithPage:(int)page since_id:(NSString*)since_id;
- (void)getUserTimelineWithScreenName:(NSString*)screenName page:(int)page since_id:(NSString*)since_id;
- (void)getDirectMessagesWithPage:(int)page since_id:(NSString*)since_id;
- (void)getSentDirectMessagesWithPage:(int)page;
- (void)getFavoriteWithScreenName:(NSString*)screenName page:(int)page since_id:(NSString*)since_id;
- (void)getStatusWithStatusId:(NSString*)statusId;
- (void)createFavoriteWithID:(NSString*)messageId;
- (void)destroyFavoriteWithID:(NSString*)messageId;
- (void)post:(NSString*)tweet reply_id:(NSString*)reply_id;

@property (readonly) int requestPage;
@property (readonly) BOOL requestForDirectMessage;
@property (readwrite, retain) NSObject<TwitterClientDelegate> *delegate;

@end
