#import <UIKit/UIKit.h>
#import "Message.h"

@class Status;

@interface Status : NSObject {
	Message *message;
	CGFloat textHeight;
	CGFloat cellHeight;

	int readTrackContinueCounter;
	int readTrackCounter;
}

- (Status*)initWithMessage:(Message*)msg;
- (void)dealloc;
- (BOOL)isEqual:(Status*)anObject;
- (void)setTextHeight:(CGFloat)height;

- (BOOL)markAsRead;

- (int)updateReadTrackCounter:(int)continueCounter;

@property(readonly) Message *message;
@property(readonly) CGFloat textHeight, cellHeight;

@end
