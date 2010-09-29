#import <UIKit/UIKit.h>
#import "Status.h"

@interface SelectedCellBackgroundView : UIView {
	Status *status;
}

@property (readwrite, retain) Status *status;

@end
