#import "SettingViewController.h"
#import "ConfigurationKeys.h"
#import "UICPrototypeTableCellTextInput.h"
#import "AboutViewController.h"
#import "Configuration.h"
#import "Colors.h"
#import "AccelerometerSensor.h"
#import "AppDelegate.h"
#import "FooterSettingViewController.h"
#import "OAuthConsumer.h"

@interface SettingViewController(Private)
- (void)setupPrototypes;
	
@end

@implementation SettingViewController

- (void)setupPrototypes {
	if (groups != nil) return;
	
	NSArray *g1 = [NSArray arrayWithObjects:[UICPrototypeTableCell cellForTitle:@"Twitter Account"], nil];	
	
	//ST: voice setting section
	NSArray *gVoice = [NSArray arrayWithObjects:
					   [UICPrototypeTableCell cellForSelect:@"Voice" 
										   withSelectTitles:[NSArray arrayWithObjects:
															 @"woman",
															 @"man", nil]
										withUserDefaultsKey:ST_PREFERENCE_VOICE],
					   [UICPrototypeTableCell cellForSelect:@"Volume"
										   withSelectTitles:[NSArray arrayWithObjects:
															 @"quiet",
															 @"normal",
															 @"loud", nil]
										withUserDefaultsKey:ST_PREFERENCE_VOLUME],
					   nil];
	
	NSArray *g2 = [NSArray arrayWithObjects:
				   [UICPrototypeTableCell cellForSelect:@"Auto refresh" 
									   withSelectTitles:[NSArray arrayWithObjects:
														 @"disabled", 
														 @"1 Minute", 
														 @"1.5 Minute", 
														 @"2 Minutes", 
														 @"3 Minutes", 
														 @"5 Minutes",
														 @"10 Minutes", nil]
									withUserDefaultsKey:PREFERENCE_REFRESH_INTERVAL],
					
				   [UICPrototypeTableCell cellForSwitch:@"UseSafari" 
									withUserDefaultsKey:PREFERENCE_USE_SAFARI],

				   //[UICPrototypeTableCell cellForSwitch:@"Dark color theme" 
					//				withUserDefaultsKey:PREFERENCE_DARK_COLOR_THEME],
				   
				   [UICPrototypeTableCell cellForSwitch:@"Shake to fullscreen" 
									withUserDefaultsKey:PREFERENCE_SHAKE_TO_FULLSCREEN],
				   nil];
	
	NSArray *g3 = [NSArray arrayWithObjects:
				   [UICPrototypeTableCell cellForSwitch:@"AutoPagerize" 
									withUserDefaultsKey:PREFERENCE_SHOW_MORE_TWEETS_MODE],

				   [UICPrototypeTableCell cellForSelect:@"Initial load" 
									   withSelectTitles:[NSArray arrayWithObjects:
														 @"20 posts", 
														 @"50 Posts", 
														 @"100 Posts", 
														 @"200 Posts", nil]
									withUserDefaultsKey:PREFERENCE_FETCH_COUNT],

				   [UICPrototypeTableCell cellForSwitch:@"AutoScroll" 
									withUserDefaultsKey:PREFERENCE_AUTO_SCROLL],
				   
				   [UICPrototypeTableCell cellForSwitch:@"Left-Handed controls" 
									withUserDefaultsKey:PREFERENCE_LEFTHAND],
				   
				   nil];
	
	/*NSArray *g4 = [NSArray arrayWithObjects:
				   [UICPrototypeTableCell cellForTitle:@"Footer"],
				   nil];*/

	NSArray *g5 = [NSArray arrayWithObjects:
				   [UICPrototypeTableCell cellForTitle:@"About SpeakTweet for iPhone"],
				   nil];
	
	groups = [[NSArray arrayWithObjects:
			   [UICPrototypeTableGroup groupWithCells:g1 withTitle:nil], 
			   [UICPrototypeTableGroup groupWithCells:gVoice withTitle:nil],
			   [UICPrototypeTableGroup groupWithCells:g2 withTitle:nil], 
			   [UICPrototypeTableGroup groupWithCells:g3 withTitle:nil], 
			   //[UICPrototypeTableGroup groupWithCells:g4 withTitle:nil], 
			   [UICPrototypeTableGroup groupWithCells:g5 withTitle:nil], 
			   nil] retain];
}

- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		[self.navigationItem setTitle:@"Settings"];
	}
	return self;
}

- (void)loadView {
	[self setupPrototypes];
	[super loadView];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[Configuration instance] reload];

	[[Colors instance] setupColors];
	[[AccelerometerSensor sharedInstance] updateByConfiguration];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

	// for "Twitter account" or "Footer" cell
	/*if (([indexPath section] == 0) && [indexPath row] == 0) { //|| [indexPath section] == 3
		cell.accessoryType = UITableViewCellAccessoryNone;
	}*/
	
	// for "About SpeakTweet for iPhone" cell
	/*if ([indexPath section] == 3 && [indexPath row] == 0) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}*/

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	// for "Twitter account" cell
	if ([indexPath section] == 0 && [indexPath row] == 0) {
#ifdef ENABLE_OAUTH
		[[OAuthConsumer sharedInstance] requestToken:self.tabBarController];
#else
		[(AppDelegate*)[UIApplication sharedApplication].delegate presentTwitterAccountSettingView];
#endif
	}
	
	// for "Footer" cell
	/*if ([indexPath section] == 3 && [indexPath row] == 0) {
		UITableViewController *vc = [[[FooterSettingViewController alloc] 
									  initWithStyle:UITableViewStyleGrouped] autorelease];
		UINavigationController *nc = [[[UINavigationController alloc] 
									   initWithRootViewController:vc] autorelease];
		[nc.navigationBar setBarStyle:UIBarStyleBlackOpaque];
		[self.tabBarController presentModalViewController:nc animated:YES];
	}*/

	// for "About SpeakTweet for iPhone" cell
	if ([indexPath section] == 4 && [indexPath row] == 0) {
		UIViewController *vc = [[[AboutViewController alloc] init] autorelease];
		[self.navigationController pushViewController:vc animated:YES];
	}
	
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}


@end
