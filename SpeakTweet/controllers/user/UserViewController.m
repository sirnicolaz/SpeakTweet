#import "UserViewController.h"
#import "LinkTweetCell.h"
#import "RoundedIconView.h"
#import "Colors.h"
#import "Configuration.h"
#import "IconTextCell.h"
#import "UserTimelineViewController.h"
#import "FavoriteViewController.h"
#import "UserListViewController.h"
#import "HttpClientPool.h"

@interface UserViewController(Private)
- (void)getUserInfo;

@end


@implementation UserViewController

@synthesize message;

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
	[self.navigationItem setTitle:@"User"];
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
}


- (void)dealloc {
	[userInfo release];
    [super dealloc];
}

- (UITableViewCell *)nameCell {	
	LinkNameCell *cell = [[[LinkNameCell alloc] initWithFrame:CGRectZero] autorelease];
	[cell createCellWithName:message.name screenName:message.screenName];
	
	RoundedIconView *iconview = [[[RoundedIconView alloc] 
									  initWithFrame:CGRectMake(6.5, 6.5, 56.0, 56.0) 
									  image:message.iconContainer.iconImage 
									  round:8.0] autorelease];
	iconview.backgroundColor = [[Colors instance] oddBackground];
	[iconview addTarget:self action:@selector(replyButtonAction:)
	   forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:iconview];	
	
	
	int y = 70 ;
	{
		/*UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		[b setFrame:CGRectMake(13, y, 148, 36)];
		[b setBackgroundImage:[UIImage imageNamed:@"normal_01.png"] forState:UIControlStateNormal];
		[b setBackgroundImage:[UIImage imageNamed:@"pushed_01.png"] forState:UIControlStateHighlighted];
//		[b addTarget:self action:@selector(replyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];*/
	}
	{
		/*UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		[b setFrame:CGRectMake(13+148, y, 149, 36)];
		[b setBackgroundImage:[UIImage imageNamed:@"normal_02.png"] forState:UIControlStateNormal];
		[b setBackgroundImage:[UIImage imageNamed:@"pushed_02.png"] forState:UIControlStateHighlighted];
//		[b addTarget:self action:@selector(retweetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];*/
	}
	
	cell.accessoryType = UITableViewCellAccessoryNone;

	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (userInfo) {
		switch ([indexPath row]) {
			case 0:
				return 70; //era 120 quando c'erano i pulsanti direct message e reply (che non funzionavano in natsulion)
		}
	} else {
		if ([indexPath row] == 0) return 70; //era 100 quando c'erano i pulsanti direct message e reply (che non funzionavano in natsulion)

	}
	return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (userInfo) {
		return 6;
	} else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	Cell *cell = nil;
	if (userInfo) {
		switch(row)
		{
			case 0:
				cell = (Cell*)[self nameCell];
				break;
			default:
				{
					cell = [[[IconTextCell alloc] initWithFrame:CGRectZero] autorelease];
					switch (row) {
						case 1:
							[(IconTextCell*)cell createCellWithText:userInfo.url icon:[UIImage imageNamed:@"icons_02.png"]
																 isEven:NO];
							break;
						case 2:
							[(IconTextCell*)cell createCellWithText:[NSString stringWithFormat:@"%d updates",userInfo.statuses_count] 
												icon:[UIImage imageNamed:@"icons_03.png"]
																 isEven:YES];
							break;
						case 3:
							[(IconTextCell*)cell createCellWithText:[NSString stringWithFormat:@"%d favs",userInfo.favourites_count] 
												icon:[UIImage imageNamed:@"icons_05.png"]
																 isEven:NO];
							break;
						case 4:
							[(IconTextCell*)cell createCellWithText:[NSString stringWithFormat:@"%d following",userInfo.friends_count]
												icon:[UIImage imageNamed:@"icons_01.png"]
																 isEven:YES];
							break;
						case 5:
							[(IconTextCell*)cell createCellWithText:[NSString stringWithFormat:@"%d followers",userInfo.followers_count] 
												icon:[UIImage imageNamed:@"icons_01.png"]
																 isEven:NO];
							break;
					}
				}
				break;
				
		}
	} else {
		cell = (Cell*)[self nameCell];
	}
	return cell;
}

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	if (userInfo) {
		switch (row){
			case 2:
			{
				UserTimelineViewController *vc = [[[UserTimelineViewController alloc] init] autorelease];
				vc.screenName = userInfo.screen_name;
				[[self navigationController] pushViewController:vc animated:YES];
			}
				break;
			case 3:
			{
				FavoriteViewController *vc = [[[FavoriteViewController alloc] initWithScreenName:userInfo.screen_name] autorelease];
				[[self navigationController] pushViewController:vc animated:YES];
			}
				break;
			case 4:
			{
				UserListViewController *vc = [[[UserListViewController alloc] init] autorelease];
				vc.screenName = userInfo.screen_name;
				[[self navigationController] pushViewController:vc animated:YES];
			}
				break;
		}
	}
}

- (void)getUserInfo {
	TwitterUserClient *c = [[HttpClientPool sharedInstance] 
								idleClientWithType:HttpClientPoolClientType_TwitterUserClient];
	c.delegate = self;
	[c getUserInfoForScreenName:message.screenName];
}

- (void)twitterUserClientSucceeded:(TwitterUserClient*)sender {
	[userInfo release];
	userInfo = nil;
	
	if ([sender.users count] > 0) {
		userInfo = [[sender.users objectAtIndex:0] retain];
	}
	[self.tableView reloadData];
	
//	LOG(@"twitterUserClientSucceeded: %d", userInfo.statuses_count);
}

- (void)twitterUserClientFailed:(TwitterUserClient*)sender {
}

@end

