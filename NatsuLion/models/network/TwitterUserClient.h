#import <UIKit/UIKit.h>
#import "User.h"
#import "HttpClient.h"
#import "OAuthHttpClient.h"

@class TwitterUserClient;

@protocol TwitterUserClientDelegate
- (void)twitterUserClientSucceeded:(TwitterUserClient*)sender;
- (void)twitterUserClientFailed:(TwitterUserClient*)sender;
@end

#ifdef ENABLE_OAUTH
@interface TwitterUserClient : OAuthHttpClient {
#else
@interface TwitterUserClient : HttpClient {
#endif
@private
	NSObject<TwitterUserClientDelegate> *delegate;
	NSMutableArray *users;
}

@property (readwrite, retain) NSObject<TwitterUserClientDelegate> *delegate;

- (void)getUserInfoForScreenName:(NSString*)screen_name;
- (void)getUserInfoForUserId:(NSString*)user_id;
- (void)getFollowingsWithScreenName:(NSString*)screen_name page:(int)page;
- (void)getFollowersWithScreenName:(NSString*)screen_name page:(int)page;

@property (readonly) NSMutableArray *users;

@end
