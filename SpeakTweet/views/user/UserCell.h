#import "Cell.h"
#import "User.h"
#import "RoundedIconView.h"

@interface UserCell : Cell {
	User* user;
	BOOL isEven;
	RoundedIconView *iconView;
}

@property (readonly) User* user;

- (void)updateByUser:(User*)user isEven:(BOOL)isEven;
- (void)updateIcon;

@end
