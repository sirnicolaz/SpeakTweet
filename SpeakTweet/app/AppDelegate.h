#import <UIKit/UIKit.h>

#import "CacheCleaner.h"

@class BrowserViewController;
@class FriendsViewController;
@class MentionsViewController;
@class SentsViewController;
//@class UnreadsViewController;
@class SettingViewController;
@class FavoriteViewController;
@class DirectMessageViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, CacheCleanerDelegate> {
	UIWindow *window;
	UITabBarController *tabBarController;
	
	FriendsViewController *friendsViewController;
	MentionsViewController *replysViewController;
	SentsViewController *sentsViewController;
	//UnreadsViewController *unreadsViewController;
	SettingViewController *settingViewController;
	
	FavoriteViewController *favoriteViewController;
	
	DirectMessageViewController *directMessageViewController;

	BOOL applicationActive;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (readonly) BOOL applicationActive;

- (BOOL)isInMoreTab:(UIViewController*)vc;
- (void)presentTwitterAccountSettingView;
- (void)resetAllTimelinesAndCache;

@end

