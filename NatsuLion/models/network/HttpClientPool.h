#import <Foundation/Foundation.h>

typedef enum HttpClientPoolClientType {
	HttpClientPoolClientType_TwitterClient,
	HttpClientPoolClientType_IconDownloader,
	HttpClientPoolClientType_TwitterUserClient,
} HttpClientPoolClientType;
		
@interface HttpClientPool : NSObject {
	NSMutableArray *clientsActive;
	NSMutableArray *clientsIdle;
}

+ (HttpClientPool*)sharedInstance;

- (id)idleClientWithType:(HttpClientPoolClientType)type;
- (void)releaseClient:(id)client;
- (void)removeAllIdleObjects;
- (int)activeClientCountWithType:(HttpClientPoolClientType)type;

- (void)addIdleClientObserver:(id)observer selector:(SEL)selector;
- (void)removeIdleClientObserver:(id)observer;

@end
