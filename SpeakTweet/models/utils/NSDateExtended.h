#import <Foundation/Foundation.h>

@interface NSDate(Extended)
- (NSString*)descriptionWithTwitterStyle;
- (NSString*)descriptionWithStyle;
- (NSString*)descriptionWithRateLimitRemaining;

@end

