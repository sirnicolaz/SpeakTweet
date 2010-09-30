#import "Account.h"
#import "ConfigurationKeys.h"
#import "GTMObjectSingleton.h"

@implementation Account

GTMOBJECT_SINGLETON_BOILERPLATE(Account, sharedInstance)

- (id)init {
	if (self = [super init]) {
		userToken = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:OAUTH_PROVIDER 
																		   prefix:OAUTH_PREFIX];
		[self update];
	}
	return self;
}

- (void)update {
	[screenName release];
	[password release];

	screenName = [[[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCE_USERID] retain];
	password = [[[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCE_PASSWORD] retain];
}

- (void) dealloc {
	[userToken release];
	[screenName release];
    [super dealloc];
}

- (void)setScreenName:(NSString*)sn {
	[screenName release];
	screenName = [sn retain];
    [[NSUserDefaults standardUserDefaults] setObject:screenName forKey:PREFERENCE_USERID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)screenName {
	return screenName;
}

- (void)setPassword:(NSString*)pw {
	[password release];
	password = [pw retain];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:PREFERENCE_PASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)password {
	return password;
}

- (NSString*)footer {
	return [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCE_FOOTER];
}

- (BOOL)valid {
#ifdef ENABLE_OAUTH
	return screenName.length > 0 &&
	userToken && 
	userToken.key.length > 0 &&
	userToken.secret.length > 0;
#else
	return screenName.length > 0 && password.length > 0;
#endif
}

- (OAToken*)userToken {
	return userToken;
}

- (void)setUserToken:(OAToken*)token {
	[userToken release];
	userToken = [token retain];
	[userToken storeInUserDefaultsWithServiceProviderName:OAUTH_PROVIDER 
												   prefix:OAUTH_PREFIX];
}

- (BOOL)waitForOAuthCallback {
	return [[NSUserDefaults standardUserDefaults] boolForKey:OAUTH_WAIT_FOR_CALLBACK];
}

- (void)setWaitForOAuthCallback:(BOOL)wait {
	[[NSUserDefaults standardUserDefaults] setBool:wait forKey:OAUTH_WAIT_FOR_CALLBACK];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
