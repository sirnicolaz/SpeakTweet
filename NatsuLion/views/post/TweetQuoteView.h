#import <UIKit/UIKit.h>
#import "Message.h"

@interface TweetQuoteView : UIView {
	Message *message;
	CGFloat messageHeight;
}

@property (readonly) CGFloat messageHeight;

- (id)initWithFrame:(CGRect)frame withMessage:(Message*)message;

@end
