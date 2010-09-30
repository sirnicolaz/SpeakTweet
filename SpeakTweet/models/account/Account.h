#import <Foundation/Foundation.h>
#import "OAToken.h"

@interface Account : NSObject {
	OAToken *userToken;
	NSString *screenName;
	NSString *password;
}

+ (Account*)sharedInstance;

- (BOOL)valid;

- (void)update;

- (void)setScreenName:(NSString*)screenName;
- (NSString*)screenName;

- (void)setPassword:(NSString*)password;
- (NSString*)password;

- (OAToken*)userToken;
- (void)setUserToken:(OAToken*)token;

- (BOOL)waitForOAuthCallback;
- (void)setWaitForOAuthCallback:(BOOL)wait;

- (NSString*)footer;

@end


