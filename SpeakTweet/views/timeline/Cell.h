#import <UIKit/UIKit.h>

typedef enum {
	CellTypeNormal,
	CellTypeNoRound,
	CellTypeRound,
	CellTypeRoundSpeech,
	CellTypeRoundTop,
	CellTypeRoundBottom,

} CellType;


@protocol CellBackgroundDelegate
- (void)drawBackgroundRect:(CGRect)rect;

@end

@interface CellBackground : UIView
{
	NSObject<CellBackgroundDelegate> *delegate;
}

- (id)initWithDelegate:(NSObject<CellBackgroundDelegate>*)delegate;

@end

@interface Cell : UITableViewCell<CellBackgroundDelegate> {
	CellType cellType;
	UIColor *bgcolor;
	CGGradientRef gradientForNormal;
}

@property (readwrite) CellType cellType;
@property (readwrite,assign) UIColor *bgcolor;

- (void)drawRect:(CGRect)rect;
- (void)drawSelectedBackgroundRect:(CGRect)rect;

@end
