#import <UIKit/UIKit.h>
#import "Cell.h"

@interface LinkTweetCell : Cell {
	NSString *text;
	NSString *footer;
	CGFloat textHeight;
}

- (void)createCellWithText:(NSString*)text footer:(NSString*)footer textHeight:(CGFloat)textHeight;

@end

@interface LinkNameCell : Cell {
	NSString *name;
	NSString *screenName;
}

- (void)createCellWithName:(NSString*)name screenName:(NSString*)screenName;

@end


