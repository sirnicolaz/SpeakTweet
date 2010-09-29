#import <UIKit/UIKit.h>

@interface Alert : NSObject <UIAlertViewDelegate> {
	BOOL shown;
}

+ (id)instance;
- (void)alert:(NSString*)title withMessage:(NSString*)message;

@end
