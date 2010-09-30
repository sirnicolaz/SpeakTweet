#import "CacheCleaner.h"
#import "Cache.h"

#define _PREFERENCE_BOOTCOUNT		@"bootcount"

static CacheCleaner *_instance;

@implementation CacheCleaner

@synthesize delegate;

+ (CacheCleaner*)sharedCacheCleaner {
	if (_instance == nil) {
		_instance = [[CacheCleaner alloc] init];
	}
	return _instance;
}

- (void)dealloc {
	[delegate release];
	[super dealloc];
}

- (BOOL)bootup {
	int n = [[NSUserDefaults standardUserDefaults] integerForKey:_PREFERENCE_BOOTCOUNT];
	n++;
    [[NSUserDefaults standardUserDefaults] setInteger:n forKey:_PREFERENCE_BOOTCOUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
	
	if (n >= 3) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"An unexpected abort detected"
														 message:@"Probably it was caused by cached data. Would you like to delete all cached data?"
														delegate:self
												cancelButtonTitle:@"Cancel" 
											   otherButtonTitles:@"OK", nil] autorelease];
		[alert show];
		return YES;
	}
	
	return NO;
}

- (void)shutdown {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:_PREFERENCE_BOOTCOUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) { // OK
		[Cache removeAllCachedData];
	}
	[delegate cacheCleanerAlertClosed];
}

@end
