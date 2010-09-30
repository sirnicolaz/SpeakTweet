#import <UIKit/UIKit.h>
#import "HttpClient.h"

@class IconDownloader;

@protocol IconDownloaderDelegate
- (void)iconDownloaderSucceeded:(IconDownloader*)sender;
- (void)iconDownloaderFailed:(IconDownloader*)sender;
@end

@interface IconDownloader : HttpClient {
	NSObject<IconDownloaderDelegate> *delegate;
}

@property (readwrite, retain) NSObject<IconDownloaderDelegate> *delegate;

- (void)download:(NSString*)url;

@end
