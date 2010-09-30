#import <UIKit/UIKit.h>

@protocol CacheCleanerDelegate
- (void)cacheCleanerAlertClosed;
@end


@interface CacheCleaner : NSObject<UIAlertViewDelegate> {
	NSObject<CacheCleanerDelegate> *delegate;
}

@property (readwrite, retain) NSObject<CacheCleanerDelegate> *delegate;

+ (CacheCleaner*)sharedCacheCleaner;

- (BOOL)bootup;
- (void)shutdown;

@end
