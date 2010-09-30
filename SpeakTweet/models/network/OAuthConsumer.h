#ifdef ENABLE_OAUTH
#import <Foundation/Foundation.h>
#import "OAConsumer.h"

@interface OAuthConsumer : NSObject {
	UIViewController *rootViewController;
}

+ (OAuthConsumer*)sharedInstance;

- (OAConsumer*)consumer;

- (void)requestToken:(UIViewController*)viewController;

- (BOOL)isCallbackURL:(NSURL*)url;
- (void)accessToken:(NSURL*)callbackUrl;

@end

#endif
