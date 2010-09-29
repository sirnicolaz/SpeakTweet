#import "TimelineViewController.h"
#import "TweetPostViewController.h"
#import "AppDelegate.h"
#import "Configuration.h"

@implementation TimelineViewController(Post)

#pragma mark Private

- (void)setupPostButton {
	UIBarButtonItem *postButton = [[[UIBarButtonItem alloc] 
									initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
									target:self 
									action:@selector(postButton:)] autorelease];
	

	if ([[Configuration instance] lefthand]) {
		if (! [(AppDelegate*)[[UIApplication sharedApplication] delegate] 
			   isInMoreTab:self]){
			[[self navigationItem] setLeftBarButtonItem:postButton];
		}
		[[self navigationItem] setRightBarButtonItem:nil];
	} else {
		[[self navigationItem] setLeftBarButtonItem:nil];
		[[self navigationItem] setRightBarButtonItem:postButton];
	}
}

- (void)postButton:(id)sender {
	[TweetPostViewController present:self.tabBarController];
}

@end