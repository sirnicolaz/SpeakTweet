#import <UIKit/UIKit.h>

#import "TwitterClient.h"
#import "IconRepository.h"
#import "Status.h"
#import "StatusCell.h"
#import "AccelerometerSensor.h"
#import "Timeline.h"

#define	PLAY_BUTTON_HEIGTH		44

#define	PITCH							200
#define	VARIANCE						20
#define	SPEED							1.0

//slt voice best params: 200, 20, 1.0

@class FliteWrapper;
@class AppDelegate;
@class TweetViewController;
@class Status;
@class RoundedIconView;
@class TweetPostViewController;
@class EGORefreshTableHeaderView;

@interface TimelineViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>{
	//ST: play calculating mode
	UIActivityIndicatorView *activityView;
	UIImageView* overlayLayer;
	NSURL* urlToPlay;
	NSInteger tweetToPlay;
	
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
	
	UIButton *playButton;
	
	UIButton *moreButton;
				
	// Accerlerometer
	UIView *tableViewSuperView;
	CGRect tableViewOriginalFrame;		
	
	BOOL disableColorize;

	// ReadTrack
	int readTrackContinueCounter;
	NSTimer *readTrackTimer;
	
	NSString *lastTopStatusId;
	
	//ST: it's the next index to be read by the speaker.
	//For test purpose we have just one index now
	//but we will setup an array of indexes for each table
	NSObject *locker;
	NSInteger nextIndexToRead;
	FliteWrapper *fliteEngine;
	NSString *selectedVoice;
	float volume;
	
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
- (void)setReloadButtonNormal;
- (void)setupClearButton;
- (NSInteger)getVisibleCellTableIndexAtPosition:(NSInteger)position;
- (void)playTweets;
- (void)stopPlaying;
- (void)setupSpeaker;
- (void)stopActivityIndicator;
- (void)startActivityIndicator;
- (void)displayLayer:(BOOL)state toHeight:(NSInteger)height;
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



