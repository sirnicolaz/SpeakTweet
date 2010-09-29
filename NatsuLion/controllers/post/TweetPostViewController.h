#import <UIKit/UIKit.h>
#import "TweetPostView.h"

@class AppDelegate;

@interface TweetPostViewController : UIViewController <UITextViewDelegate> {
	TweetPostView *tweetPostView;
	UILabel *textLengthView;
	int maxTextLength;
}

+ (void)present:(UIViewController*)parentViewController;
+ (void)dismiss;
+ (BOOL)active;

@end
