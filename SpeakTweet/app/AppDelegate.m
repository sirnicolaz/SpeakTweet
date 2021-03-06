#import "AppDelegate.h"
#import "Account.h"
#import "TweetPostViewController.h"
#import "FriendsViewController.h"
#import "MentionsViewController.h"
#import "SentsViewController.h"
//#import "UnreadsViewController.h"
#import "SettingViewController.h"
#import "CacheCleaner.h"
#import "FavoriteViewController.h"
#import "DirectMessageViewController.h"
#import "RateLimit.h"
#import "GTMRegex.h"
#import "TwitterPost.h"
#import "OAuthConsumer.h"
#import "OAToken.h"
#import "ConfigurationKeys.h"
#import "TwitterAccountViewController.h"


// ST: for the background image on the navigation bar
@implementation UINavigationBar (Background)

- (void)drawRect:(CGRect)rect {
	UIImage *image = [UIImage imageNamed: @"navigation.png"];
	[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end
// ST: end custom


@implementation AppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize applicationActive;

#define PREFERENCE_TABORDER		@"tabItemTitlesForTabOrder"

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[splashView removeFromSuperview];
	[splashView release];
}



//splash screen fade out
- (void) splashScreenAnimation {
	splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)];
	splashView.image = [UIImage imageNamed:@"Default.png"];
	[window addSubview:splashView];
	[window bringSubviewToFront:splashView];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.50];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:window cache:YES];
	[UIView setAnimationDelegate:self]; 
	[UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
	splashView.alpha = 0.0;
	//splashView.frame = CGRectMake(-60, -60, 440, 600);
	[UIView commitAnimations];
}



- (void)setTabOrderIfSaved {
	NSArray *tabItemTitles = [[NSUserDefaults standardUserDefaults] arrayForKey:PREFERENCE_TABORDER];
	NSMutableArray *views = [NSMutableArray array];
	if ([tabItemTitles count] > 0) {
		for (int i = 0; i < [tabItemTitles count]; i++){
			for (UIViewController *vc in tabBarController.viewControllers) {
				if ([vc.tabBarItem.title isEqualToString:[tabItemTitles objectAtIndex:i]]) {
					[views addObject:vc];
				}
			}
		}
		tabBarController.viewControllers = views;
	}
}

- (void)saveTabOrder {
	NSMutableArray *tabItemTitles = [NSMutableArray array];
	for (UIViewController *v in tabBarController.viewControllers) {
		[tabItemTitles addObject:v.tabBarItem.title];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:tabItemTitles forKey:PREFERENCE_TABORDER];
}

- (void)createViews {
	tabBarController = [[UITabBarController alloc] init];
		
	friendsViewController = [[FriendsViewController alloc] init];
	replysViewController = [[MentionsViewController alloc] init];
	friendsViewController.mentionsViewController = replysViewController;
	replysViewController.friendsViewController = friendsViewController;
	
	directMessageViewController	= [[DirectMessageViewController alloc] init];
	//sentsViewController = [[SentsViewController alloc] init];
	//unreadsViewController = [[UnreadsViewController alloc] init];
	
	//unreadsViewController.friendsViewController = friendsViewController;
	//unreadsViewController.replysViewController = replysViewController;
	//unreadsViewController.directMessageViewController = directMessageViewController;
		
	settingViewController = [[SettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
	
	favoriteViewController  = [[FavoriteViewController alloc] initWithScreenName:nil];
	
	
	UINavigationController *nfri = [[[UINavigationController alloc] 
										initWithRootViewController:friendsViewController] autorelease];
	
	[[RateLimit shardInstance] updateNavigationBarColor:nfri.navigationBar];
	
	UINavigationController *nrep = [[[UINavigationController alloc] 
										initWithRootViewController:replysViewController] autorelease];
	//UINavigationController *nsen = [[[UINavigationController alloc] 
	//									initWithRootViewController:sentsViewController] autorelease];
	//UINavigationController *nunr = [[[UINavigationController alloc] 
	//									initWithRootViewController:unreadsViewController] autorelease];
	UINavigationController *nset = [[[UINavigationController alloc] 
										initWithRootViewController:settingViewController] autorelease];
	UINavigationController *nsfv = [[[UINavigationController alloc]
										initWithRootViewController:favoriteViewController] autorelease];
	UINavigationController *nsdm = [[[UINavigationController alloc]
										initWithRootViewController:directMessageViewController] autorelease];
	
	[nfri.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	[nfri.tabBarItem setTitle:@"Timeline"];
	[nfri.tabBarItem setImage:[UIImage imageNamed:@"tab1tl.png"]];
	friendsViewController.tabBarItem = nfri.tabBarItem; // is it need (to show badge)?
	
	[nrep.navigationBar setBarStyle:UIBarStyleDefault];
	[nrep.tabBarItem setTitle:@"Mentions"];
	[nrep.tabBarItem setImage:[UIImage imageNamed:@"tab2at.png"]];
	replysViewController.tabBarItem  = nrep.tabBarItem; // is it need (to show badge)?

	[nsdm.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	[nsdm.tabBarItem setTitle:@"DM"];
	[nsdm.tabBarItem setImage:[UIImage imageNamed:@"tab3dm.png"]];
	directMessageViewController.tabBarItem  = nsdm.tabBarItem; // is it need (to show badge)?
	
	/*[nsen.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	[nsen.tabBarItem setTitle:@"Sents"];
	[nsen.tabBarItem setImage:[UIImage imageNamed:@"sent.png"]];*/

	/*[nunr.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	[nunr.tabBarItem setTitle:@"Unreads"];
	[nunr.tabBarItem setImage:[UIImage imageNamed:@"unread.png"]];*/
	
	[nsfv.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	[nsfv.tabBarItem setTitle:@"Favorites"];
	[nsfv.tabBarItem setImage:[UIImage imageNamed:@"tab4fav.png"]];

	[nset.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	[nset.tabBarItem setTitle:@"Settings"];
	[nset.tabBarItem setImage:[UIImage imageNamed:@"tab5set.png"]];
	
	[[RateLimit shardInstance] updateNavigationBarColor:tabBarController.moreNavigationController.navigationBar];

	[tabBarController setViewControllers:
		[NSArray arrayWithObjects:nfri, nrep, nsdm, nsfv, nset, nil]];

	[self setTabOrderIfSaved];
	
	
	
	//ST: custom tabbat background
	CGRect frame = CGRectMake(0, 0, 320, 49);
	UIView* view = [[UIView alloc] initWithFrame:frame];
	UIImage* tabBarBackgroundImage = [UIImage imageNamed:@"tabbar.png"];
	UIColor* color = [[UIColor alloc] initWithPatternImage:tabBarBackgroundImage];
	
	[view setBackgroundColor:color];
	[color release];
	[[tabBarController tabBar] insertSubview:view atIndex:0];
	[view release];
}

- (void)startup {
	[self createViews];
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window addSubview:tabBarController.view];
	[window makeKeyAndVisible];
	[self splashScreenAnimation];
	
#ifdef ENABLE_OAUTH	
	if (! [[Account sharedInstance] waitForOAuthCallback] && 
		! [[Account sharedInstance] valid]) {
		[[OAuthConsumer sharedInstance] requestToken:tabBarController];
	}
#else
	if (![[Account sharedInstance] valid]) {		
		[self presentTwitterAccountSettingView];
	}	
#endif
	
	applicationActive = YES;
	
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	CacheCleaner *cc = [CacheCleaner sharedCacheCleaner];
	cc.delegate = self;
	BOOL alertShown = [cc bootup];
	if (!alertShown) {
		[self startup];
	}
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSString * notFirstRun = [defaults stringForKey:@"NotFirstRun"];
	
	if (notFirstRun == nil) {
		[defaults setValue:@"This is the first time you run this app!" forKey:@"NotFirstRun"];
		[defaults synchronize];
	
		
		UIAlertView *alert = [[UIAlertView alloc] 
									 initWithTitle:@"Advertise" 
									 message:@"This free version shows iAd advertising and offers only a woman voice.\nThe complete version is iAd free and offers a man voice too."
									 delegate:nil cancelButtonTitle:@"Not now..." 
									 otherButtonTitles:nil];
		[alert addButtonWithTitle:@"App Store"];
		alert.delegate = self;
		
		[alert show];
		[alert release];
		
	}
	
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1)
	{
		[[UIApplication sharedApplication]
		 openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/speaktweet/id396175265?mt=8"]];
	}
}



- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	LOG(@"handleOpenURL:%@", url);
	if ([[url path] isEqualToString:@"/post"]) {
		NSString *query = [url query];
		NSString *text = (NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																				 (CFStringRef)query,
																				 CFSTR(""),
																				 kCFStringEncodingUTF8);
		[[TwitterPost shardInstance] updateText:text];
	} 
#ifdef ENABLE_OAUTH
	else if ([[OAuthConsumer sharedInstance] isCallbackURL:url]) {
		[[OAuthConsumer sharedInstance] accessToken:url];
		[[Account sharedInstance] setWaitForOAuthCallback:NO];
	}
#endif
	return YES;
}

- (void)cacheCleanerAlertClosed {
	[self startup];
}

- (void)dealloc {
	[friendsViewController release];
	[replysViewController release];
	//[sentsViewController release];
	//[unreadsViewController release];
	[settingViewController release];
	[favoriteViewController release];
	[directMessageViewController release];
	
	[tabBarController release];
	[window release];
	[super dealloc];
}

- (void)tabBarController:(UITabBarController *)tabBarController 
			didSelectViewController:(UIViewController *)viewController {
	LOG(@"view selected: %@", [[viewController tabBarItem] title]);
}

- (void)applicationWillResignActive:(UIApplication *)application {
	LOG(@"applicationWillResignActive");
	applicationActive = FALSE;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	LOG(@"applicationDidBecomeActive");
	applicationActive = TRUE;

	[friendsViewController.timeline prefetch];
	[replysViewController.timeline prefetch];
	[directMessageViewController.timeline prefetch];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	LOG(@"applicationWillTerminate");
	[self saveTabOrder];
	
	[replysViewController.timeline disactivate];
	[directMessageViewController.timeline disactivate];
	[friendsViewController.timeline disactivate];
	//[sentsViewController.timeline disactivate];
	//[favoriteViewController.timeline disactivate];
	
	[[TwitterPost shardInstance] backupText];
	
	[[CacheCleaner sharedCacheCleaner] shutdown];
}

- (void)presentTwitterAccountSettingView {
	UITableViewController *vc = [[[TwitterAccountViewController alloc] 
								  initWithStyle:UITableViewStyleGrouped] autorelease];
	UINavigationController *nc = [[[UINavigationController alloc] 
								   initWithRootViewController:vc] autorelease];
	[nc.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	[tabBarController presentModalViewController:nc animated:YES];
}

- (BOOL)isInMoreTab:(UIViewController*)vc {
	int cnt = 0;
	for (UINavigationController *v in tabBarController.viewControllers) {
		if (v.viewControllers.count > 0 && [v.viewControllers objectAtIndex:0] == vc) {
			if (cnt < 4) {
				return NO;
			} else {
				return YES;
			}
		}
		cnt++;
	}
	return YES;
}

- (void)resetAllTimelinesAndCache {
	[replysViewController.timeline clearAndRemoveCache];
	[directMessageViewController.timeline clearAndRemoveCache];
	[friendsViewController.timeline clearAndRemoveCache];
	//[sentsViewController.timeline clearAndRemoveCache];
	//[favoriteViewController.timeline clearAndRemoveCache];
}

@end
