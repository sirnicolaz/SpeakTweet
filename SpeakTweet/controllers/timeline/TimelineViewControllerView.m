#import "TimelineViewController.h"
#import "Configuration.h"
#import "Colors.h"
#import "AppDelegate.h"
#import "FliteWrapper.h"

@interface TimelineViewController(Private)
- (UIView*)moreTweetView;
- (UIView*)autopagerizeTweetView;
- (UIView*)nowloadingView;

@end


@implementation TimelineViewController(View)

#pragma mark Private

- (void)setupSpeaker{

	if (selectedVoice != [[Configuration instance] voice]) {
		selectedVoice = [[Configuration instance] voice];
		[fliteEngine setVoice:selectedVoice];
	}
	
	if(volume != [[Configuration instance] volume]){
		volume = [[Configuration instance] volume];
		[fliteEngine setVolume:volume];
	}

	// e questo no? bisogna metterlo dopo che setta la voce
	// (ecco perché non andava nei primissimi test)
	//[fliteEngine setPitch:140.0 variance:10.0 speed:1.3];
	
}

-(void)prepareSpeaker
{
	[fliteEngine speakText:@""];
}

- (UIView*)nowloadingView {
	
	UIActivityIndicatorView *ai = [[[UIActivityIndicatorView alloc] 
									initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] 
									autorelease];
	[ai startAnimating];

	CGSize s = ai.frame.size;
	ai.frame = CGRectMake((320-s.width)/2, (368-s.height)/2 - 44, s.width, s.height); // !!
	return ai;
}

- (void)setReloadButtonNormal:(BOOL)normal {
	//ST: here we have images for the reload button that can be replaced with the one for the play button
	//if ([[Configuration instance] darkColorTheme]) {
		if (normal) {
			[headReloadButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
			[headReloadButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateHighlighted];
		} else {
			[headReloadButton setBackgroundImage:[UIImage imageNamed:@"play_loading.png"] forState:UIControlStateNormal];
			[headReloadButton setBackgroundImage:[UIImage imageNamed:@"play_loading.png"] forState:UIControlStateHighlighted];
		}
	/*} else {
		if (normal) {
			[headReloadButton setBackgroundImage:[UIImage imageNamed:@"reload_button_normal.png"] forState:UIControlStateNormal];
			[headReloadButton setBackgroundImage:[UIImage imageNamed:@"reload_button_pushed.png"] forState:UIControlStateHighlighted];
		} else {
			[headReloadButton setBackgroundImage:[UIImage imageNamed:@"reload_button_loading.png"] forState:UIControlStateNormal];
			[headReloadButton setBackgroundImage:[UIImage imageNamed:@"reload_button_loading_pushed.png"] forState:UIControlStateHighlighted];
		}
	}*/
}

//- (UIView*)playButtonItem{
	
	//UIBarButtonItem *b = [[UIBarButtonItem alloc] 
//							initWithImage:[UIImage imageNamed:@"play.jpg"]
//	 //					  initWithImage:[UIImage imageNamed:@"unread_clear.png"]
//									style:UIBarButtonItemStyleBordered 
//									target:self action:@selector(playTweets:)];
	/*UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
	b.frame = CGRectMake(0, 0, 320, 55);
	[b addTarget:self action:@selector(playTweetsAction:) forControlEvents:UIControlEventTouchUpInside];
	
	[b retain];
	return b;
	
}*/

- (void)setupTableView {
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	//self.tableView.tableHeaderView = [self reloadView];
	
	
	//UIBarButtonItem *playButton;

	//[self.view addSubview:[self playButtonItem]];
	

}

- (void)setupNavigationBar {
/*	reloadButton = [[UIBarButtonItem alloc] 
					initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
					target:self action:@selector(reloadButton:)];
	
	[[self navigationItem] setRightBarButtonItem:reloadButton];
*/
}

- (void)insertNowloadingViewIfNeeds {
	if (timeline.count == 0 && nowloadingView == nil) {
		nowloadingView = [[self nowloadingView] retain];
		[self.tableView addSubview:nowloadingView];
	}
}

- (void)removeNowloadingView {
	if (nowloadingView) {
		[nowloadingView removeFromSuperview];
		[nowloadingView release];
		nowloadingView = nil;
	}
}

//-(IBAction)reloadButton:(id)sender {
//	if (![timeline isClientActive]) {
//		[timeline getTimelineWithPage:0 autoload:NO];
//	} else {
//		[timeline clientCancel];
//	}
//}


//ST: set the next row index to read (still dunno if useful)
-(void)setNextIndexToRead:(NSInteger)value{
	@synchronized(nextIndexToReadLocker){
		nextIndexToRead = value;
		NSLog(@"New index to read %i", value);
	}
}

//ST: get the next visible row index to read
-(NSInteger)getNextIndexToRead{
	@synchronized(nextIndexToReadLocker){
		return nextIndexToRead;
	}
}

-(NSIndexPath*)getVisibleCellIndexPathAtPosition:(NSInteger)position{
	
	//UITableView *tableView = self.tableView; // Or however you get your table view
	NSArray *paths = [tableView indexPathsForVisibleRows];
	NSIndexPath *indexPath = nil;
	
	//  For getting the cells themselves
	if(paths != nil){
		NSInteger currentPosition = 0;
		for( NSIndexPath *path in paths)
		{
			if(currentPosition == position){
				indexPath = path;
			}
			currentPosition++;
		}
	}
	
	return indexPath;

}

//ST: once the visible row are retrieved, it returns the index of the first one
-(NSInteger)getVisibleCellTableIndexAtPosition:(NSInteger)position{
	NSInteger index = -1;
	
	NSIndexPath *path = [self getVisibleCellIndexPathAtPosition:position];
	
	if(path != nil){
		index = [path row];
	}
	
	return index;	
	
}


//ST: after taking the first row height, the function scroll the table view
//to the next row to be the first visible
-(void)scrollToNextRow{
	
	//Get the second visible row (table start from index 0)
	NSIndexPath *secondCellIndexPath = [self getVisibleCellIndexPathAtPosition:1];
	
	if (secondCellIndexPath != nil) {
		
		//ST: it means that the scroll reched the end
		if([secondCellIndexPath row]+1 <= [self getNextIndexToRead]){
			
			[self setNextIndexToRead:[self getNextIndexToRead]+1];
			
		}
		else{
			[self.tableView scrollToRowAtIndexPath:secondCellIndexPath
								  atScrollPosition:UITableViewScrollPositionTop
										  animated:YES];
		
			[self setNextIndexToRead:[secondCellIndexPath row]+1];
		}
	}
}

-(void)scrollToFirstVisible{
	
	NSIndexPath *firstVisibleIndexPath = [self getVisibleCellIndexPathAtPosition:0];
	
	if (firstVisibleIndexPath != nil) {
				
		[self.tableView scrollToRowAtIndexPath:firstVisibleIndexPath
							  atScrollPosition:UITableViewScrollPositionTop
									  animated:YES];
		
		[self setNextIndexToRead:[firstVisibleIndexPath row]+1];
	}
}

//ST:play the tweet at the given position
-(void)playTweetAtIndex:(NSInteger)index{
	
	Status *currentStatus = [timeline statusAtIndex:index];
	Message *currentMessage = currentStatus.message;
	NSString *messageToSay = [currentMessage messageToSay];
	if(messageToSay != nil){
		[fliteEngine speakText:messageToSay];
	}
	else{
		isPlaying = NO;
		[self stopPlaying];
	}
	NSLog(@"Playing '%@'", messageToSay);
	NSLog(@"At index %i", index);
}

//ST: delegate method to be called by on play button press
-(IBAction)playTweetsAction:(id)sender{
	
	if(isPlaying == NO){
		isPlaying = YES;
		
		//ST: ActivityIndicator stuff...
		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityView.frame = CGRectMake(245.0f, 10.0f, 20.0f, 20.0f);
		activityView.hidesWhenStopped = YES;
		[playButtonView addSubview:activityView];
		
		[activityView startAnimating];
		
		
		synthWorking = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 10.0f, 100.0f, 20.0f)];
		synthWorking.text = @"Stop vocal";
		synthWorking.backgroundColor = [UIColor blackColor];
		synthWorking.textColor = [UIColor whiteColor];
		synthWorking.textAlignment = UITextAlignmentCenter;
		synthWorking.font = [UIFont boldSystemFontOfSize:16];
		[playButtonView addSubview:synthWorking];
		
		

		
		//for some reasons, seekToFirstVisible can't keep the table
		//view as it is if the first row is the first visible one. So
		//in order to play the first tweet it's necessary to directly
		//use playTweetAtIndex without scrolling the view.
		if([self getNextIndexToRead] == 0 && [self getVisibleCellTableIndexAtPosition:0] == 0)
		{
			[self setNextIndexToRead:1];
			[self playTweetAtIndex:0];
		}
		else {
			[self seekToFirstVisible];
		}
	}
	else {
		[activityView stopAnimating];
		[activityView release];
		
		[synthWorking removeFromSuperview];
		[synthWorking release];
		
		isPlaying = NO;
		[self stopPlaying];
	}
}

-(BOOL)isIndexInTableView:(NSInteger)index{
	
	if([self.tableView numberOfRowsInSection:1] > index){
		return YES;
	}
	return YES;
	
}

//ST: it plays the next tweet
-(void)playTweets{
	//ST: here we're gonna write what needed for palying tweets
	NSInteger indexToRead;
	indexToRead = [self getNextIndexToRead];
	[self playTweetAtIndex:indexToRead];
	[self scrollToNextRow];
}


//ST: stop playing tweets
- (void)stopPlaying{
	[fliteEngine stopTalking];
}


-(void)seekToFirstVisible{
	
	//ST: it's necessary to reset the speaker to get the audioplayer working after stop. Dunno why
	//[self setupSpeaker];
	[self scrollToFirstVisible];
	[self playTweets];
	
}

- (void)iconUpdate:(NSNotification*)sender {
	IconContainer *container = (IconContainer*)sender.object;
	NSArray *vc = [self.tableView visibleCells];
	for (StatusCell *cell in vc) {
		if (container == cell.status.message.iconContainer){
			[cell updateIcon];
		}
	}
}

- (void)clearButton:(id)sender {
	[timeline markAllAsRead];
	[self.tableView reloadData];
	[self updateBadge];
}

- (UIBarButtonItem*)clearButtonItem {
	UIBarButtonItem *b = [[UIBarButtonItem alloc] 
						  initWithImage:[UIImage imageNamed:@"checkmark.png"]
//						  initWithImage:[UIImage imageNamed:@"unread_clear.png"]
						  style:UIBarButtonItemStyleBordered 
						  target:self action:@selector(clearButton:)];
	[b autorelease];
	return b;
}


- (void)setupClearButton {
	if ([[Configuration instance] lefthand]) {
		[[self navigationItem] setRightBarButtonItem:[self clearButtonItem]];
	} else {
		if (! [(AppDelegate*)[[UIApplication sharedApplication] delegate] 
				isInMoreTab:self]){
			[[self navigationItem] setLeftBarButtonItem:[self clearButtonItem]];
			
			//ST: let's try to put the header button out of the timeline table view
			//buttonBarView = [[UIViewController alloc] init];
			//[buttonBarView.view addSubview:[self reloadView]];
			//[[self navigationItem] setLeftBarButtonItem:[self playButtonItem]];
			
		}
	}
}


@end