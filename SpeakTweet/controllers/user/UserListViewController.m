#import "UserListViewController.h"
#import "LinkTweetCell.h"
#import "RoundedIconView.h"
#import "Colors.h"
#import "Configuration.h"
#import "IconTextCell.h"
#import "UserTimelineViewController.h"
//#import "FavoriteViewController.h"
#import "UserCell.h"
#import "UserViewController.h"
#import "User.h"
#import "HttpClientPool.h"

@interface UserListViewController (Private)
- (void)getUserInfo;


@end


@implementation UserListViewController

@synthesize screenName;

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)setupTableView {
	UITableView *tv = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
													style:UITableViewStylePlain] autorelease];	
	tv.delegate = self;
	tv.dataSource = self;
	tv.autoresizesSubviews = YES;
	tv.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	self.view = tv;
}

- (void)viewDidLoad {
	[self setupTableView];
	((UITableView*)self.view).autoresizesSubviews = YES;
	[self.navigationItem setTitle:@"User List"];
}

- (void)viewWillAppear:(BOOL)animated {
	[self getUserInfo];
	
	NSIndexPath *tableSelection = [(UITableView*)self.view indexPathForSelectedRow];
	[(UITableView*)self.view deselectRowAtIndexPath:tableSelection animated:NO];
	
	//	[(UITableView*)self.view reloadData];
	
	((UITableView*)self.view).backgroundColor = [[Colors instance] scrollViewBackground];
	//if ([[Configuration instance] darkColorTheme]) {
		((UITableView*)self.view).indicatorStyle = UIScrollViewIndicatorStyleWhite;
	//} else {
	//	((UITableView*)self.view).indicatorStyle = UIScrollViewIndicatorStyleBlack;
	//}
	
	[IconRepository addObserver:self selectorSuccess:@selector(iconUpdate:)];
}

- (void)viewWillDisappear:(BOOL)animated {
	[IconRepository removeObserver:self];
}

- (void)dealloc {
	[users release];
    [super dealloc];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return users.count;
}


#define CELL_RESUSE_ID2	@"fuga"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UserCell *cell = (UserCell*)[tableView dequeueReusableCellWithIdentifier:CELL_RESUSE_ID2];
	if (cell == nil) {
		cell = [[[UserCell alloc] initWithFrame:CGRectZero reuseIdentifier:CELL_RESUSE_ID2] autorelease];
	}
	[cell updateByUser:[users objectAtIndex:indexPath.row] isEven:(indexPath.row%2==0)];
	return cell;
}

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *tableSelection = [(UITableView*)self.view indexPathForSelectedRow];
	[(UITableView*)self.view deselectRowAtIndexPath:tableSelection animated:NO];
	
	User *user = [users objectAtIndex:indexPath.row];
	
	UserViewController *vc = [[[UserViewController alloc] init] autorelease];
	vc.message = [[[Message alloc] init] autorelease];
	vc.message.screenName = user.screen_name;
	vc.message.name = user.name;
	[[self navigationController] pushViewController:vc animated:YES];
	
}

- (void)getUserInfo {
	TwitterUserClient *c = [[HttpClientPool sharedInstance] 
								idleClientWithType:HttpClientPoolClientType_TwitterUserClient];
	c.delegate = self;
//	[c getFollowersWithScreenName:screenName page:1];
	[c getFollowingsWithScreenName:screenName page:1];
}

- (void)twitterUserClientSucceeded:(TwitterUserClient*)sender {
/*	LOG(@"%d users fetched.", sender.users.count);

	for (User *u in sender.users) {
		LOG(@"%@(%@) :%@", u.screen_name, u.name, u.description);
	}
*/	
	[users release];
	users = [sender.users retain];
	[self.tableView reloadData];
}

- (void)twitterUserClientFailed:(TwitterUserClient*)sender {
}

- (void)iconUpdate:(NSNotification*)sender {
	IconContainer *container = (IconContainer*)sender.object;
	NSArray *vc = [self.tableView visibleCells];
	for (UserCell *cell in vc) {
		if (container == cell.user.iconContainer){
			[cell updateIcon];
		}
	}
}


@end
