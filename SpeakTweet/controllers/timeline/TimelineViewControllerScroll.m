#import "TimelineViewController.h"
#import "Configuration.h"
#import "FliteWrapper.h";

@implementation TimelineViewController(Scroll)

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height) {
		if (![timeline isClientActive] && self.tableView.tableFooterView != nil) {
			if ([[Configuration instance] showMoreTweetMode]) {
				[self autopagerize];
			}
		}
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
	[self stopPlaying];

//	LOG(@"scrollViewWillBeginDragging");
	if (! [self readTrackTimerActivated]) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self 
												 selector:@selector(stopReadTrackTimer) 
												   object:nil];
		[self startReadTrackTimer];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (! decelerate) {
//		LOG(@"scrollViewDidEndDragging");
		[NSObject cancelPreviousPerformRequestsWithTarget:self 
												 selector:@selector(stopReadTrackTimer) 
												   object:nil];
		[self performSelector:@selector(stopReadTrackTimer) withObject:nil afterDelay:2.0];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//	LOG(@"scrollViewDidEndDecelerating");
	[NSObject cancelPreviousPerformRequestsWithTarget:self 
											 selector:@selector(stopReadTrackTimer) 
											   object:nil];
	[self performSelector:@selector(stopReadTrackTimer) withObject:nil afterDelay:2.0];
	
	//ST: to resume the play from the current new position
	
	NSLog(@"Stop decelerating");
	if( isPlaying == YES){
		[self playTweets];
	}
}

@end