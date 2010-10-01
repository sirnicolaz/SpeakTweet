#import "TimelineViewController.h"
#import "TweetViewController.h"

#import "EGORefreshTableHeaderView.h"
#import "FliteTTS.h"

@implementation TimelineViewController(TableView)
#pragma mark Private

- (CGFloat)cellHeightForIndex:(int)index {
	Status *s = [timeline statusAtIndex:index];	
	return s.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = 0.0;
	@synchronized(timeline) {
		height = [self cellHeightForIndex:[indexPath row]];
	}
	return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger n = 0;
	@synchronized(timeline) {
		n = [timeline count];
	}
	return n;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	Status *s = [timeline statusAtIndex:row];
	BOOL isEven = [timeline isEven:row];
	
	StatusCell *cell = (StatusCell*)[tv dequeueReusableCellWithIdentifier:CELL_RESUSE_ID];
	if (cell == nil) {
		cell = [[[StatusCell alloc] initWithIsEven:isEven] autorelease];
	}
	
	if (disableColorize) {
		[cell setDisableColorize];
	}
	
	[cell updateCell:s isEven:isEven];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[self normalScreenTimeline];
	
	Status *s = nil;
	@synchronized(timeline) {
		s = [timeline statusAtIndex:[indexPath row]];
	}
	
	TweetViewController *lvc = [[[TweetViewController alloc] 
									init] autorelease];
	lvc.message = s.message;
	[[self navigationController] pushViewController:lvc animated:YES];
}
//ST: load on drag methods implementation
-(void)reloadTimeline {
	if (![timeline isClientActive]) {
		[timeline getTimelineWithPage:0 autoload:NO];
	} else {
		[timeline clientCancel];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
		_reloading = YES;
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
	
	//ST: in this case the user has dragged the scroll to e specific position and tha view will not decelerate
	if (decelerate == NO && isPlaying == YES) {
		
		[self seekToFirstVisible];

	}
}

- (void)dataSourceDidFinishLoadingNewData{
	
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful
}

- (void)reloadTableViewDataSource{
	//  should be calling your tableviews model to reload
	//  put here just for demo
	[self reloadTimeline];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}


- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	[self dataSourceDidFinishLoadingNewData];
}


@end