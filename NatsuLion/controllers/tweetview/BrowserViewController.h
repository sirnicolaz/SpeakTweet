#import <UIKit/UIKit.h>
#import "AccelerometerSensor.h"
#import "WebView.h"

@interface BrowserViewController : UIViewController<UIWebViewDelegate> {
	NSString *url;
	WebView *webView;
	UIToolbar *toobarTop;
	UIToolbar *toobarBottom;

	BOOL loading;
	
	UIBarButtonItem *title;
	UIBarButtonItem *reloadButton;
	UIBarButtonItem *prevButton;
	UIBarButtonItem *nextButton;

	NSMutableArray *toobarTopItems;
}

@property (readwrite, retain) NSString *url;

@end
