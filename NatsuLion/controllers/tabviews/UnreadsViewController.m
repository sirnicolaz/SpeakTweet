#import "UnreadsViewController.h"
#import "FriendsViewController.h"
#import "MentionsViewController.h"
#import "DirectMessageViewController.h"

@implementation UnreadsViewController

@synthesize friendsViewController, replysViewController, directMessageViewController;

- (void)dealloc {
	[friendsViewController release];
	[replysViewController release];
	[directMessageViewController release];
	[super dealloc];
}

- (void)setupNavigationBar {
	[[self navigationItem] setRightBarButtonItem:[self clearButtonItem]];
	[self.navigationItem setTitle:@"Unreads"];
//	[super setupPostButton];
}


- (void)viewWillAppear:(BOOL)animated {
	[timeline release];
	timeline = [[Timeline alloc] initWithDelegate:self 
								  withArchiveFilename:nil];
	timeline.readTracker = YES;

	[timeline appendStatuses:[friendsViewController.timeline unreadStatuses]];
	[timeline appendStatuses:[replysViewController.timeline unreadStatuses]];
	[timeline appendStatuses:[directMessageViewController.timeline unreadStatuses]];
	
	[super viewWillAppear:animated]; //with reload
}

- (void)viewWillDisappear:(BOOL)animated {
	[timeline release];
	timeline = nil;
}

- (BOOL)doReadTrack {
	return FALSE;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.navigationItem setTitle:@"Unreads"];
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}
*/

- (void)clearButton:(id)sender {
	[friendsViewController.timeline markAllAsRead];
	[replysViewController.timeline markAllAsRead];
	[directMessageViewController.timeline markAllAsRead];
	[timeline release];
	timeline = nil;
	[super.tableView reloadData];
}


@end
