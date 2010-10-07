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

- (void)setReloadButtonNormal{
	//ST: here we have images for the reload button that can be replaced with the one for the play button
	//if ([[Configuration instance] darkColorTheme]) {
	[playButton setBackgroundImage:[UIImage imageNamed:@"play_w.png"] forState:UIControlStateNormal];
	[playButton setBackgroundImage:[UIImage imageNamed:@"play_pw.png"] forState:UIControlStateHighlighted];
}



- (void)setupTableView {
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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


//ST: set the next row index to read (still dunno if useful)
-(void)setNextIndexToRead:(NSInteger)value{
	@synchronized(locker){
		nextIndexToRead = value;
		NSLog(@"New index to read %i", value);
	}
}

//ST: get the next visible row index to read
-(NSInteger)getNextIndexToRead{
	@synchronized(locker){
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
		NSLog(@"Setting index %i", indexToRead);
		[self setNextIndexToRead:indexToRead];
	}
}

//ST:play the tweet at the given position
-(void)playTweetAtIndex:(id)sender{
	NSInteger next = [self getNextIndexToRead];
	Status *currentStatus = [timeline statusAtIndex:next];
	Message *currentMessage = currentStatus.message;
	NSString *messageToSay = [currentMessage messageToSay];
	
	if(messageToSay != nil){
		
		//setta il tweet come letto (senza il segno a lato nella cella new-dark.png)
		currentStatus.message.status = _MESSAGE_STATUS_READ;
		
		NSURL* messageURL = [fliteEngine synthesize:messageToSay
													 withPitch:PITCH
												 withVariance:VARIANCE
													 withSpeed:SPEED];
	
		NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																				selector:@selector(stopActivityIndicator) object:self];
		NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
		
		[opQueue addOperation: operation];
		
		@synchronized(locker){
			if(next == tweetToPlay){
				[fliteEngine speakText:messageURL];
			}
		}
			NSLog(@"Playing '%@'", messageToSay);
			
	}
	else{
			NSLog(@"Stop playing");
			isPlaying = NO;
			[self stopPlaying];
			[self displayLayer:FALSE toHeight:480];
	}
}

//ST: delegate method to be called by on play button press
-(IBAction)playTweetsAction:(id)sender{
	
	if(isPlaying == NO){
		[playButton setBackgroundImage:[UIImage imageNamed:@"play_s.png"] forState:UIControlStateNormal];
		[playButton setBackgroundImage:[UIImage imageNamed:@"play_ps.png"] forState:UIControlStateHighlighted];

		//for some reasons, seekToFirstVisible can't keep the table
		//view as it is if the first row is the first visible one. So
		//in order to play the first tweet it's necessary to directly
		//use playTweetAtIndex without scrolling the view.
		if([self getNextIndexToRead] == 0 && [self getVisibleCellTableIndexAtPosition:0] == 0)
		{
			[self setNextIndexToRead:0];
		}
		else {
			[self scrollToFirstVisible];
		}
		if(![self hasTableViewReachedTheEnd]){
			[self startActivityIndicator];
		}
		else {
			[self displayLayer:FALSE toHeight:480];
		}

		isPlaying = YES;
		@synchronized(locker){
			tweetToPlay = [self getNextIndexToRead];
		}
		
		NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																					selector:@selector(playTweetAtIndex:) object:self];
		NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
			
		[opQueue addOperation: operation];
	}
	else {
		[playButton setBackgroundImage:[UIImage imageNamed:@"play_w.png"] forState:UIControlStateNormal];
		[playButton setBackgroundImage:[UIImage imageNamed:@"play_pw.png"] forState:UIControlStateHighlighted];

		isPlaying = NO;
		[self stopPlaying];
		[self displayLayer:FALSE toHeight:480];
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
	if(![self hasTableViewReachedTheEnd]){
		[self startActivityIndicator];
	}
	else {
		[self displayLayer:FALSE toHeight:480];
	}
	
	@synchronized(locker){
		tweetToPlay = [self getNextIndexToRead];
	}
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(playTweetAtIndex:) object:self];
	NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
	
	[opQueue addOperation: operation];
	
}


//ST: stop playing tweets
- (void)stopPlaying{
	@synchronized(locker){
		tweetToPlay = -1;
		[fliteEngine stopTalking];
	}
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

-(void)displayLayer:(BOOL)state toHeight:(NSInteger)height{
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.45];
	[UIView setAnimationDelegate:self]; 
	
	if (state == TRUE) {
		//lo setta in modo che la prima cella sia visibile
		overlayLayer.frame = CGRectMake(0, PLAY_BUTTON_HEIGTH + height, 320, 480);
	}
	else {
		//lo fa sparire
		overlayLayer.frame = CGRectMake(0, height, 320, 480);
	}
	
	[UIView commitAnimations];
}



-(void) startActivityIndicator {
	
	NSIndexPath* cellIndexPath;
	if(isPlaying == FALSE)
	{
		cellIndexPath = [self getVisibleCellIndexPathAtPosition:0];
	}
	else {
		cellIndexPath = [self getVisibleCellIndexPathAtPosition:1];
	}

	UITableViewCell* cellToNotCover = [self.tableView cellForRowAtIndexPath:cellIndexPath];
	
	[self.view addSubview:overlayLayer];
	[self displayLayer:TRUE toHeight:cellToNotCover.bounds.size.height];
	
	//ST: ActivityIndicator stuff...
	[activityView startAnimating];
	
}


-(void)stopActivityIndicator {
	
	NSLog(@"Stopping activity indicator");
	//ST: ActivityIndicator stuff...
	[activityView stopAnimating];
	NSLog(@"Stopped");
}


@end