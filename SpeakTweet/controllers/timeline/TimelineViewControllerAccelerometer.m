#import "TimelineViewController.h"
#import "TweetPostViewController.h"
#import "AppDelegate.h"

@implementation TimelineViewController(Accerlerometer)

#pragma mark Private

- (void)fullScreenTimeline {
	if (tableViewSuperView == nil) {
		if ([TweetPostViewController active]) {
			[TweetPostViewController dismiss];
		}
		tableViewSuperView = self.tableView.superview;
		[self.tableView removeFromSuperview];
		[[self tabBarController].view addSubview:self.tableView];
		CGSize s = [self tabBarController].view.frame.size;
		tableViewOriginalFrame = self.tableView.frame;
		self.tableView.frame = CGRectMake(0, 0, s.width, s.height);
	}
}

- (void)normalScreenTimeline {
	if (tableViewSuperView) {
		[self.tableView removeFromSuperview];
		self.tableView.frame = tableViewOriginalFrame;
		[tableViewSuperView addSubview:self.tableView];
		tableViewSuperView = nil;
	}
}

- (void)toggleFullScreenTimeline {
	if (tableViewSuperView) {
		[self normalScreenTimeline];
	} else {
		[self fullScreenTimeline];
	}
	
	//	[SoundEffects playShakeSound];
}

#pragma mark AccelerometerSensorDelegate

- (void)accelerometerSensorDetected {
	[self toggleFullScreenTimeline];
}

@end
