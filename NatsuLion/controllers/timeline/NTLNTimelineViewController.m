#import "NTLNTimelineViewController.h"
#import "NTLNColors.h"
#import	"NTLNConfiguration.h"
#import "NTLNAccelerometerSensor.h"
#import "NTLNIconRepository.h"
#import "NTLNRateLimit.h"
#import "FliteTTS_HTS.h"
#import "EGORefreshTableHeaderView.h"

@interface NTLNTimelineViewController (Private)

- (void)dataSourceDidFinishLoadingNewData;

@end

@implementation NTLNTimelineViewController

@synthesize reloading=_reloading;

@synthesize timeline, tableView;

- (void) dealloc {
	[self stopReadTrackTimer];
	[timeline release];
	[lastReloadTime release];
	[nowloadingView release];
	[footerActivityIndicatorView release];
	[lastTopStatusId release];
	[headReloadButton release];
	[moreButton release];
	[playButtonView release];
	[tableView release];
	[fliteEngine release];
	
	//ST: we add a new view ought to be placed above the table. Here we'll have the static play button
	//[buttonBarView release];
	nextIndexToReadLocker = [[NSObject alloc] init];
	 
	
    [super dealloc];
}

//ST: create a view with the play button
- (UIView*)reloadView {
	//ST: here we have the reload button that can be replaced by the play button
	UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
	b.frame = CGRectMake(0, 0, 320, 55);
	//[b addTarget:self action:@selector(reloadButton:) forControlEvents:UIControlEventTouchUpInside];
	//ST: we try now to replace the reloadButton function with the playTweets one
	[b addTarget:self action:@selector(playTweetsAction:) forControlEvents:UIControlEventTouchUpInside];
	
	headReloadButton = [b retain];
	
	[self setReloadButtonNormal:YES];
	playButtonView = b;
	
	return b;
}


- (void)viewDidLoad {
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 55, 320, 313)
											 style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = self;
	
	//ST: the next index to be read by the speaker is 0, the beginning of the table
	//NSInteger zeroInteger = 0;
	nextIndexToRead = 0;
	isPlaying = NO;
	[self setupSpeaker];
	[self prepareSpeaker];
	[self setupTableView];
	
	//ST: setting the load on drag handler
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, 320.0f, self.tableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.tableView addSubview:refreshHeaderView];
		self.tableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
	
	[self.view addSubview:[self reloadView]];
	[self.view addSubview:tableView];
	
}

- (void)viewWillAppear:(BOOL)animated {
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
	[self.tableView reloadData];
	[self updateFooterView];
	
	self.tableView.backgroundColor = [[NTLNColors instance] scrollViewBackground];
	if ([[NTLNConfiguration instance] darkColorTheme]) {
		self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	} else {
		self.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
	}
	
	[[NTLNRateLimit shardInstance] updateNavigationBarColor:self.navigationController.navigationBar];
	[NTLNIconRepository addObserver:self selectorSuccess:@selector(iconUpdate:)];

	[self setupNavigationBar];
	[self setReloadButtonNormal:![timeline isClientActive]];
}

- (void)viewDidAppear:(BOOL)animated {
	enable_read = TRUE;
	[timeline activate];
	[timeline getTimelineWithPage:0 autoload:YES];
	[self.tableView flashScrollIndicators];
	[NTLNAccelerometerSensor sharedInstance].delegate = self;
	[self setupSpeaker];
}

- (void)viewWillDisappear:(BOOL)animated {
	[NTLNIconRepository removeObserver:self];
	[NTLNAccelerometerSensor sharedInstance].delegate = nil;
	[self stopPlaying];
	isPlaying = FALSE;
	enable_read = FALSE;
	[timeline suspend];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
	LOG(@"NTLNStatusViewController#didReceiveMemoryWarning");
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

