#import <UIKit/UIKit.h>
#import "IconDownloader.h"

@class IconContainer;

/*
@protocol IconDownloadDelegate
- (void) finishedToGetIcon:(IconContainer*)sender;
- (void) failedToGetIcon:(IconContainer*)sender;
@end
*/

@interface IconContainer : NSObject <IconDownloaderDelegate>
{
	UIImage *iconImage;
	NSString *url;
	BOOL downloading;
}

@property (readonly) UIImage *iconImage;
@property (readonly) NSString *url;


- (id)initWithIconURL:(NSString*)url;
- (BOOL)loadCache;
- (void)requestDownload;

@end

@interface IconRepository : NSObject  {
    NSMutableDictionary *urlToContainer;
	NSMutableArray *downloadQueue;
	NSString *iconCacheRootPath;
}

@property (readonly) NSString *iconCacheRootPath;

+ (IconRepository*) instance;
+ (UIImage*) defaultIcon;

- (IconContainer*)iconContainerForURL:(NSString*)url;

+ (void)addObserver:(id)observer selectorSuccess:(SEL)success;
+ (void)removeObserver:(id)observer;

@end