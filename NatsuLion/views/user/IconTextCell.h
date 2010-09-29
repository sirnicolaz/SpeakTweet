#import "Cell.h"

@interface IconTextCell : Cell {
	NSString *text;
	UIImage *icon;
	BOOL isEven;
}

- (void)createCellWithText:(NSString*)text icon:(UIImage*)icon isEven:(BOOL)isEven;

@end
