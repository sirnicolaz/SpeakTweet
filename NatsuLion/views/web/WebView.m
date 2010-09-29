#import "WebView.h"
#import "GTMObjectSingleton.h"
#import "Colors.h"

@implementation WebView

GTMOBJECT_SINGLETON_BOILERPLATE(WebView, sharedInstance)

- (id)init {
	if (self = [super initWithFrame:[[UIScreen mainScreen] applicationFrame]]) {
		self.backgroundColor = [[Colors instance] scrollViewBackground];
		self.scalesPageToFit = YES;
		self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		self.autoresizesSubviews = YES;
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
}

@end
