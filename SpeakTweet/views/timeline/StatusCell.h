#import <UIKit/UIKit.h>
#import "RoundedIconView.h"
#import "Status.h"

#define CELL_RESUSE_ID		@"STATUSCELL_REUSE_ID"

@interface StatusCell : UITableViewCell
{
	RoundedIconView *iconView;
	UIImageView *unreadView, *starView;
	Status *status;
	BOOL isEven;
	BOOL disableColorize;
}

@property (readonly) Status *status;

+ (UIFont*)textFont;
+ (UIFont*)metaFont;
+ (CGFloat)getTextboxHeight:(NSString *)str;
+ (void)drawTexts:(Status*)status selected:(BOOL)selected;
	
- (id)initWithIsEven:(BOOL)iseven;
- (void)updateCell:(Status*)status isEven:(BOOL)isEven;
- (void)updateIcon;
- (void)updateBackgroundColor;
- (void)setDisableColorize;

@end

