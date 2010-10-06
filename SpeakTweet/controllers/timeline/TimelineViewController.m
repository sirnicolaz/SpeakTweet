#import "TimelineViewController.h"
#import "Colors.h"
#import	"Configuration.h"
#import "AccelerometerSensor.h"
#import "IconRepository.h"
#import "RateLimit.h"
#import "FliteWrapper.h"
#import "EGORefreshTableHeaderView.h"

@interface TimelineViewController (Private)

- (void)dataSourceDidFinishLoadingNewData;

@end

@implementation TimelineViewController

@synthesize reloading=_reloading;

@synthesize timeline, tableView;

- (id)init {
	[super init];	
	fliteEngine = [[FliteWrapper alloc] initWithOnFinishDelegate:self whenFinishPlayingExecute:@selector(playTweets)];

	selectedVoice = [[Configuration instance] voice];
	[fliteEngine setVoice:selectedVoice];	
	
	volume = [[Configuration instance] volume];
	[fliteEngine setVolume:volume];
	
	return self;
}


- (void) dealloc {
	[self stopReadTrackTimer];
	[timeline release];
	[lastReloadTime release];
	[nowloadingView release];
	[footerActivityIndicatorView release];
	[lastTopStatusId release];
	[playButton release];
	[moreButton release];
	[playButtonView release];
	[tableView release];
	[fliteEngine release];
	
	[activityView release];
	[overlayLayer release];
	
	
	//ST: we add a new view ought to be placed above the table. Here we'll have the static play button
	//[buttonBarView release];
	nextIndexToReadLocker = [[NSObject alloc] init];
	 
	
    [super dealloc];
}

//ST: create a view with the play button
- (UIView*)reloadView {
	//ST: here we have the reload button that can be replaced by the play button
	UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
	//ST: play button sizes
	b.frame = CGRectMake(0, 0, 320, 44);
	//[b addTarget:self action:@selector(reloadButton:) forControlEvents:UIControlEventTouchUpInside];
	//ST: we try now to replace the reloadButton function with the playTweets one
	[b addTarget:self action:@selector(playTweetsAction:) forControlEvents:UIControlEventTouchUpInside];
	
	playButton = [b retain];
	
	[self setReloadButtonNormal:YES];
	playButtonView = b;
	
	return b;
}


- (void)viewDidLoad {
	
	//ST: position of tableView
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 323)
											 style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = self;
	
	[self setupTableView];
	
	//ST: setting the load on drag handler
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, 320.0f, self.tableView.bounds.size.height)];
		//ST: set the color of the background for the refreshHeader (gray is 40-40-40-1)
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
		[self.tableView addSubview:refreshHeaderView];
		self.tableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
	
	[self.view addSubview:[self reloadView]];
	[self.view addSubview:tableView];
	
	urlToPlay = [[NSURL alloc] init];
	
	//ST: overlay layer
	overlayLayer = [[UIImageView alloc] initWithFrame:CGRectMake(0, 480, 320, 480)];
	overlayLayer.layer.masksToBounds = YES;
	overlayLayer.layer.borderColor = [[UIColor blackColor] CGColor];
	overlayLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
	[self.view addSubview:overlayLayer];
	
	
	//ST: ActivityIndicator stuff...
	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityView.frame = CGRectMake(320/2 - 17, 80, 34.0f, 34.0f);
	activityView.hidesWhenStopped = YES;
	[overlayLayer addSubview:activityView];	
	
}

- (void)viewWillAppear:(BOOL)animated {
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
	[self.tableView reloadData];
	[self updateFooterView];
	
	self.tableView.backgroundColor = [[Colors instance] scrollViewBackground];
	//if ([[Configuration instance] darkColorTheme]) {
		self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	//} else {
	//	self.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
	//}
	
	[[RateLimit shardInstance] updateNavigationBarColor:self.navigationController.navigationBar];
	[IconRepository addObserver:self selectorSuccess:@selector(iconUpdate:)];

	
	//ST: the next index to be read by the speaker is 0, the beginning of the table
	//NSInteger zeroInteger = 0;
	nextIndexToRead = 0;
	isPlaying = NO;
	[self setupSpeaker];
	
	[self setupNavigationBar];
	[self setReloadButtonNormal:![timeline isClientActive]];
}

- (void)viewDidAppear:(BOOL)animated {
	enable_read = TRUE;
	[timeline activate];
	[timeline getTimelineWithPage:0 autoload:YES];
	[self.tableView flashScrollIndicators];
	[AccelerometerSensor sharedInstance].delegate = self;
	//[self setupSpeaker];
}

- (void)viewWillDisappear:(BOOL)animated {
	[IconRepository removeObserver:self];
	[AccelerometerSensor sharedInstance].delegate = nil;
	
	//ST: stop playing stuff
	[self stopPlaying];
	isPlaying = FALSE;
	enable_read = FALSE;
	
	[timeline suspend];
	
	[self displayLayer:FALSE toHeight:480];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
	LOG(@"StatusViewController#didReceiveMemoryWarning");
//	[timeline suspend];
}


//ST: just to avoid warnings
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}


@end

