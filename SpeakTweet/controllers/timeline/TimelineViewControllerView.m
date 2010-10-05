#import "TimelineViewController.h"
#import "Configuration.h"
#import "Colors.h"
#import "AppDelegate.h"
#import "FliteWrapper.h"

#include <unistd.h>

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



- (UIView*)nowloadingView {
	
	UIActivityIndicatorView *ai = [[[UIActivityIndicatorView alloc] 
									initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] 
									autorelease];
	[ai startAnimating];

	CGSize s = ai.frame.size;
	ai.frame = CGRectMake((320-s.width)/2, (368-s.height)/2 - PLAY_BUTTON_HEIGTH, s.width, s.height); // !!
	return ai;
}

- (void)setReloadButtonNormal:(BOOL)normal {
	//ST: here we have images for the reload button that can be replaced with the one for the play button
	//if ([[Configuration instance] darkColorTheme]) {
		if (normal) {
			[playButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
			[playButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateHighlighted];
		} else {
			[playButton setBackgroundImage:[UIImage imageNamed:@"play_loading.png"] forState:UIControlStateNormal];
			[playButton setBackgroundImage:[UIImage imageNamed:@"play_loading.png"] forState:UIControlStateHighlighted];
		}
	/*} else {
		if (normal) {
			[playButton setBackgroundImage:[UIImage imageNamed:@"reload_button_normal.png"] forState:UIControlStateNormal];
			[playButton setBackgroundImage:[UIImage imageNamed:@"reload_button_pushed.png"] forState:UIControlStateHighlighted];
		} else {
			[playButton setBackgroundImage:[UIImage imageNamed:@"reload_button_loading.png"] forState:UIControlStateNormal];
			[playButton setBackgroundImage:[UIImage imageNamed:@"reload_button_loading_pushed.png"] forState:UIControlStateHighlighted];
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
		for(NSIndexPath *path in paths)
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


-(BOOL)hasTableViewReachedTheEnd
{
	NSArray *paths = [self.tableView indexPathsForVisibleRows];
	NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:0];
	
	for (NSIndexPath *path in paths) {
		if ([path row] == lastRowIndex-1)
		{
			return YES;
		}
	}
	return NO;
}

//ST: after taking the first row height, the function scroll the table view
//to the next row to be the first visible
-(void)scrollToNextRow{
	
	//Get the second visible row (table start from index 0)
	NSIndexPath *secondVisibleCellIndexPath = [self getVisibleCellIndexPathAtPosition:1];
	if (secondVisibleCellIndexPath != nil) {

		[self.tableView scrollToRowAtIndexPath:secondVisibleCellIndexPath
								  atScrollPosition:UITableViewScrollPositionTop
										  animated:YES];
		
		
		//If the secondCellIndexPath and the secondVisibleCellIndexPath are equal, it means
		//that the scroll view hasn't moved and so the table reached the end.
		if ([self hasTableViewReachedTheEnd] && 
			[secondVisibleCellIndexPath row] <= [self getNextIndexToRead]) {
			
			NSLog(@"Table finished");
			[self setNextIndexToRead:[self getNextIndexToRead]+1];
		}
		else
		{
			NSLog(@"Continuing");
			[self setNextIndexToRead:[secondVisibleCellIndexPath row]];
		}
	}
}

-(void)scrollToFirstVisible{
	
	NSIndexPath *firstVisibleIndexPath = [self getVisibleCellIndexPathAtPosition:0];
	
	if (firstVisibleIndexPath != nil) {
				
		[self.tableView scrollToRowAtIndexPath:firstVisibleIndexPath
									 atScrollPosition:UITableViewScrollPositionTop
												animated:YES];
		
		NSInteger indexToRead = [self getVisibleCellTableIndexAtPosition:0];
		[self setNextIndexToRead:indexToRead];
	}
}

//ST:play the tweet at the given position
-(void)playTweetAtIndex:(id)sender{
	
	//BOOL state = [self setVisualPlayMode];
	
	Status *currentStatus = [timeline statusAtIndex:[self getNextIndexToRead]];
	Message *currentMessage = currentStatus.message;
	NSString *messageToSay = [currentMessage messageToSay];
	
	if(messageToSay != nil){
			NSURL* messageURL = [fliteEngine synthesize:messageToSay];
		
			[(TimelineViewController*)sender stopActivityIndicator];
			
			[fliteEngine speakText:messageURL];
		
			NSLog(@"Playing '%@'", messageToSay);
			
		}
		else{
			NSLog(@"Stop playing");
			isPlaying = NO;
			[self stopPlaying];
			[self removeVisualPlayMode];
	}
}

//ST: delegate method to be called by on play button press
-(IBAction)playTweetsAction:(id)sender{
	
	if(isPlaying == NO){
		isPlaying = YES;
		[self startActivityIndicator];
		//for some reasons, seekToFirstVisible can't keep the table
		//view as it is if the first row is the first visible one. So
		//in order to play the first tweet it's necessary to directly
		//use playTweetAtIndex without scrolling the view.
		if([self getNextIndexToRead] == 0 && [self getVisibleCellTableIndexAtPosition:0] == 0)
		{
			[self setNextIndexToRead:0];
			[self startActivityIndicator];
		}
		else {
			[self scrollToFirstVisible];
			[self startActivityIndicator];
		}

			
			NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																					selector:@selector(playTweetAtIndex:) object:self];
			NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
			
			[opQueue addOperation: operation];
	}
	else {
		isPlaying = NO;
		[self stopPlaying];
		[self removeVisualPlayMode];
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
	[self scrollToNextRow];
	[self startActivityIndicator];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(playTweetAtIndex:) object:self];
	NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
	
	[opQueue addOperation: operation];
	
}


//ST: stop playing tweets
- (void)stopPlaying{
	[fliteEngine stopTalking];
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
			
		}
	}
}


- (BOOL)setVisualPlayMode {
	
	
	[playButtonView addSubview:activityView];
	[playButtonView addSubview:synthWorking];
	[activityView startAnimating];
	

	return TRUE;
}


-(void) overlayAnimation:(CGRect)new_frame{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.45];
	[UIView setAnimationDelegate:self]; 
	overlayLayer.frame = new_frame;
	[UIView commitAnimations];
}


-(void) playModeButtonAnimation:(BOOL)state {
	if (state == TRUE) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.45];
		[UIView setAnimationDelegate:self]; 
		playButton.frame = CGRectMake(0, -44, 320, 44);
		[UIView commitAnimations];
	}
}

-(void) removeVisualPlayMode {
	
	[activityView stopAnimating];
	[synthWorking removeFromSuperview];
	[self overlayAnimation:CGRectMake(0, 480, 320, 480)];
	
}


-(void) startActivityIndicator {
	
	NSIndexPath* cellIndexPath;
	if([self getNextIndexToRead] == 0 && 
	   [self getVisibleCellTableIndexAtPosition:0] == 0)
	{
		cellIndexPath = [self getVisibleCellIndexPathAtPosition:0];
	}
	else {
		cellIndexPath = [self getVisibleCellIndexPathAtPosition:1];
	}

	UITableViewCell* cellToNotCover = [self.tableView cellForRowAtIndexPath:cellIndexPath];
	
	[self.view addSubview:overlayLayer];
	[self overlayAnimation:CGRectMake(0, PLAY_BUTTON_HEIGTH + cellToNotCover.bounds.size.height, 320, 480)];

	//ST: ActivityIndicator stuff...
	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityView.frame = CGRectMake(50.0f, 50.0f, 20.0f, 20.0f);
	activityView.hidesWhenStopped = YES;
	[overlayLayer addSubview:activityView];
	[activityView startAnimating];
	
}

@end