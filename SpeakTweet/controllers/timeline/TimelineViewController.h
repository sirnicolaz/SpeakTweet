#import <UIKit/UIKit.h>

#import "TwitterClient.h"
#import "IconRepository.h"
#import "Status.h"
#import "StatusCell.h"
#import "AccelerometerSensor.h"
#import "Timeline.h"

@class FliteTTS_HTS;
@class AppDelegate;
@class TweetViewController;
@class Status;
@class RoundedIconView;
@class TweetPostViewController;
@class EGORefreshTableHeaderView;

@interface TimelineViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>{
	Timeline *timeline;
	
	//ST: redefine the view structure to put the play button outside the table
	UIView *playButtonView;
	
	//ST: redefine the UIViewController with a UITableView field
	UITableView *tableView;
	
	//ST: state variable that specifies if the tweets are being played
	BOOL isPlaying;
	
	// Read
	BOOL badge_enable;
	
	// View
	BOOL enable_read;
	UIView *nowloadingView;
	NSDate *lastReloadTime;
	UIActivityIndicatorView *footerActivityIndicatorView;
	BOOL evenInv;
	
	UIButton *headReloadButton;
	
	//ST: we add a new view ought to be placed above the table. Here we'll have the static play button
	UIViewController *buttonBarView;
	UITabBar *playButtonTabBar;
	UIBarButtonItem *playButton;
	
	UIButton *moreButton;
				
	// Accerlerometer
	UIView *tableViewSuperView;
	CGRect tableViewOriginalFrame;		
	
	BOOL disableColorize;

	// ReadTrack
	int readTrackContinueCounter;
	NSTimer *readTrackTimer;
	
	NSString *lastTopStatusId;
	
	//ST: it's the next index to be read by the speaker. For test purpose we have just one index now
	//but we will setup an array of indexes for each table
	NSObject *nextIndexToReadLocker;
	NSInteger nextIndexToRead;
	FliteTTS_HTS *fliteEngine;
	
	//ST: load on drag handler
	EGORefreshTableHeaderView *refreshHeaderView;
	
	//  Reloading should really be your tableviews model class
	//  Putting it here for demo purposes 
	BOOL _reloading;
}

@property (readonly) Timeline *timeline;

@property(assign,getter=isReloading) BOOL reloading;

@property(nonatomic, retain) UITableView *tableView;
@end

@interface TimelineViewController(Accerlerometer) <AccelerometerSensorDelegate>
- (void)normalScreenTimeline;

@end

@interface TimelineViewController(View)
- (void)insertNowloadingViewIfNeeds;
- (void)removeNowloadingView;
- (void)setupTableView;
- (void)setupNavigationBar;
- (UIBarButtonItem*)clearButtonItem;
- (void)setReloadButtonNormal:(BOOL)normal;
- (void)setupClearButton;
- (NSInteger)getVisibleCellTableIndexAtPosition:(NSInteger)position;
- (void)playTweets;
- (void)stopPlaying;
- (void)seekToFirstVisible;
- (void)setupSpeaker;
-(void)prepareSpeaker;
@end


@interface TimelineViewController(Scroll) <UIScrollViewDelegate>
@end

@interface TimelineViewController(Read)
- (void)startReadTrackTimer;
- (void)stopReadTrackTimer;
- (BOOL)readTrackTimerActivated;
- (void)updateBadge;
- (BOOL)doReadTrack;

@end

@interface TimelineViewController(Post)
- (void)setupPostButton;
- (void)postButton:(id)sender;

@end

@interface TimelineViewController(TableView) <UITableViewDataSource, UITableViewDelegate>
//ST: load on drag property and methods

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (CGFloat)cellHeightForIndex:(int)index;

@end

@interface TimelineViewController(Paging)
- (void)autopagerize;
- (void)updateFooterView;
- (void)footerActivityIndicator:(BOOL)active;

@end

@interface TimelineViewController(Timeline) <TimelineDelegate>
@end


