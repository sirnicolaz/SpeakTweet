#import "TweetViewController.h"
#import "Message.h"
#import "BrowserViewController.h"
#import "FriendsViewController.h"
#import "TweetPostViewController.h"
#import "Account.h"
#import "RoundedIconView.h"
#import "UserTimelineViewController.h"
#import "Configuration.h"
#import "Colors.h"
#import "CellBackgroundView.h"
#import "AppDelegate.h"
#import "IconTextCell.h"
#import "LinkTweetCell.h"
#import "Cell.h"
#import "TwitterPost.h"
#import "UserViewController.h"
#import "NSDateExtended.h"
#import "ConversationViewController.h"
#import "Images.h"
#import "HttpClientPool.h"
#import "GTMRegex.h"

#define TEXT_FONT_SIZE	16.0

@implementation URLPair
@synthesize url, text, screenName, conversation;

- (void)dealloc {
	[url release];
	[text release];
	[screenName release];
	[super dealloc];
}
@end


@interface TweetViewController(Private)
- (CGFloat)getTextboxHeight:(NSString *)str;
- (UITableViewCell *)screenNameCell;
- (UITableViewCell *)urlCell:(URLPair*)pair isEven:(BOOL)isEven;
- (UITableViewCell *)nameCell;
- (UITableViewCell *)tweetCell;
- (void)parseToken;

@end


@implementation TweetViewController

@synthesize message;

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
	[self.navigationItem setTitle:@"Tweet"];
}

- (void)makeLinks {
	if (links == nil) {
		links = [[NSMutableArray alloc] init];

		if (message.in_reply_to_status_id.length > 0) {
			URLPair *pair = [[URLPair alloc] init];
			pair.text = [NSString stringWithFormat:@"in reply to %@", message.in_reply_to_screen_name];
			pair.conversation = YES;
			[links addObject:pair];
		}

		URLPair *pair = [[URLPair alloc] init];
		pair.text = message.screenName;
		[links addObject:pair];
		[self parseToken];
	}
}

- (void)setupPostButton {
	UIBarButtonItem *postButton = [[[UIBarButtonItem alloc] 
									initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
									target:self 
									action:@selector(replyButtonAction:)] autorelease];
	
	[[self navigationItem] setRightBarButtonItem:postButton];
}

- (void)viewWillAppear:(BOOL)animated {
	NSIndexPath *tableSelection = [(UITableView*)self.view indexPathForSelectedRow];
	[(UITableView*)self.view deselectRowAtIndexPath:tableSelection animated:NO];
	
	[self makeLinks];
	
	[(UITableView*)self.view reloadData];
	
	((UITableView*)self.view).backgroundColor = [[Colors instance] scrollViewBackground];
	//if ([[Configuration instance] darkColorTheme]) {
		((UITableView*)self.view).indicatorStyle = UIScrollViewIndicatorStyleWhite;
	//} else {
	//	((UITableView*)self.view).indicatorStyle = UIScrollViewIndicatorStyleBlack;
	//}

	if (![[Configuration instance] lefthand]) {
		[self setupPostButton];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
	LOG(@"TweetViewController#didReceiveMemoryWarning");
}

- (void)dealloc {
	LOG(@"TweetViewController#dealloc");
	[links release];
	[message release];
	[favAI release];
	[favButton release];
	[super dealloc];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch ([indexPath row]) {
		case 0:
			return 70;
		case 1:
			return 70 + [self getTextboxHeight:message.text] + 12;
	}
	return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2 + [links count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	Cell *cell = nil;
	switch(row)
	{
		case 0:
			cell = (Cell*)[self nameCell];
			break;
		case 1:
			cell = (Cell*)[self tweetCell];
			break;
		default:
			cell = (Cell*)[self urlCell:[links objectAtIndex:row-2] isEven:((row%2)==0)];
			break;
	}
	
	if (row >= [links count] + 1) {
		cell.cellType = CellTypeRoundBottom;
	}
	
	return cell;
}

- (void)switchToUserTimelineViewWithScreenName:(NSString*)screenName {
	UserTimelineViewController *utvc = [[[UserTimelineViewController alloc] init] autorelease];
	utvc.screenName = screenName;
	[[self navigationController] pushViewController:utvc animated:YES];
}

- (void)switchToUserTimelineViewWithScreenNames:(NSArray*)screenNames {
	UserTimelineViewController *utvc = [[[UserTimelineViewController alloc] init] autorelease];
	utvc.screenNames = screenNames;
	[[self navigationController] pushViewController:utvc animated:YES];
}

- (void)switchToBrowserViewWithURL:(NSString*)url {
	if ([[Configuration instance] useSafari]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	} else {
		BrowserViewController *browser = [[[BrowserViewController alloc] init] autorelease];
		browser.url = url;
		[[self tabBarController] presentModalViewController:browser animated:YES]; 
	}
}

- (void)switchToUserViewWithScreenName:(NSString*)screenName {
	UserViewController *vc = [[[UserViewController alloc] init] autorelease];
	vc.message = message;
	[[self navigationController] pushViewController:vc animated:YES];
}

- (void)switchToConversationView {
	ConversationViewController *vc = [[[ConversationViewController alloc] init] autorelease];
	vc.rootMessage = message;
	[[self navigationController] pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	if (row == 0) {
		[self switchToUserViewWithScreenName:message.screenName];
	} else if (row == 1) {
		
	} else {
		URLPair *pair = [links objectAtIndex:row-2];
		
		if (pair.screenName) {
			NSArray *names = [[NSArray alloc] initWithObjects:message.screenName, pair.screenName, nil];
			[self switchToUserTimelineViewWithScreenNames:names];
			[names release];
		} else if (pair.url) {
			[self switchToBrowserViewWithURL:pair.url];
		} else if (pair.conversation) {
			[self switchToConversationView];
		} else {
			[self switchToUserTimelineViewWithScreenName:message.screenName];
		}		
	}
}

- (void)favButtonAction:(id)sender {
	TwitterClient *twitterClient = [[HttpClientPool sharedInstance] 
							 idleClientWithType:HttpClientPoolClientType_TwitterClient];
	twitterClient.delegate = self;

	if (message.favorited) {
		[twitterClient destroyFavoriteWithID:message.statusId];
	} else {
		[twitterClient createFavoriteWithID:message.statusId];
	}
	
	UIImage *buttonImage = nil;
	//if ([[Configuration instance] darkColorTheme]) {
		buttonImage = [UIImage imageNamed:@"pushed_black_04.png"];
	//} else {
	//	buttonImage = [UIImage imageNamed:@"pushed_04.png"];
	//}
	[favButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
	[favButton addSubview:favAI];
	[favAI startAnimating];
}

- (void)replyButtonAction:(id)sender {
	if (message.replyType == _MESSAGE_REPLY_TYPE_DIRECT) {
		[[TwitterPost shardInstance] createDMPost:message.screenName withReplyMessage:message];
	} else {
		[[TwitterPost shardInstance] createReplyPost:[@"@" stringByAppendingString:message.screenName] 
										withReplyMessage:message];
	}
	[TweetPostViewController present:self.tabBarController];
}

- (void)retweetButtonAction:(id)sender {
	[[TwitterPost shardInstance] updateText:[NSString stringWithFormat:@"RT @%@: %@", message.screenName, message.text]];
	[TweetPostViewController present:self.tabBarController];
}

- (CGFloat)getTextboxHeight:(NSString *)str
{
	CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE] 
				  constrainedToSize:CGSizeMake(300.0, 280.0)];
	CGFloat h = size.height;
	if (h < 20) return 20.0;
	return h;
}

- (UIImage*)favButtonImage{
	if (message.favorited) {
		//if ([[Configuration instance] darkColorTheme]) {
			return [UIImage imageNamed:@"normal_black_04_.png"];
		//} else {
		//	return [UIImage imageNamed:@"normal_04_.png"];
		//}
	} else {
		//if ([[Configuration instance] darkColorTheme]) {
			return [UIImage imageNamed:@"normal_black_04.png"];
		//} else {
		//	return [UIImage imageNamed:@"normal_04.png"];
		//}
	}
}

- (UITableViewCell *)nameCell {	
	LinkNameCell *cell = [[[LinkNameCell alloc] initWithFrame:CGRectZero] autorelease];
	[cell createCellWithName:message.name screenName:message.screenName];

	RoundedIconView *iconview = [[[RoundedIconView alloc] 
									  initWithFrame:CGRectMake(6.5, 6.5, 56.0, 56.0) 
									  image:message.iconContainer.iconImage 
									  round:8.0] autorelease];
	iconview.backgroundColor = [UIColor clearColor];
	[iconview addTarget:self action:@selector(replyButtonAction:)
	   forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:iconview];	

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (UITableViewCell *)tweetCell {
	CGFloat textHeight = [self getTextboxHeight:message.text];
	LinkTweetCell *cell = [[[LinkTweetCell alloc] initWithFrame:CGRectZero] autorelease];

	NSString *footer;
	if (message.source.length > 0) {
		footer = [NSString stringWithFormat:@"%@ from %@", [message.timestamp descriptionWithTwitterStyle], message.source];
	} else {
		footer = [message.timestamp descriptionWithTwitterStyle];
	}
	[cell createCellWithText:message.text footer:footer textHeight:textHeight];
	
	textHeight += 12;
	
	
	UIImage *bimage[5];
	//if ([[Configuration instance] darkColorTheme]) {
		bimage[0] = [UIImage imageNamed:@"normal_black_03.png"];
		bimage[1] = [UIImage imageNamed:@"pushed_black_03.png"];
		bimage[2] = [UIImage imageNamed:@"pushed_black_04.png"];
		bimage[3] = [UIImage imageNamed:@"normal_black_05.png"];
		bimage[4] = [UIImage imageNamed:@"pushed_black_05.png"];
	//} else {
		//bimage[0] = [UIImage imageNamed:@"normal_03.png"];
		//bimage[1] = [UIImage imageNamed:@"pushed_03.png"];
		//bimage[2] = [UIImage imageNamed:@"pushed_04.png"];
		//bimage[3] = [UIImage imageNamed:@"normal_05.png"];
		//bimage[4] = [UIImage imageNamed:@"pushed_05.png"];
	//}
		
	int y = textHeight + 13*2;
	{
		UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		[b setFrame:CGRectMake(13, y, 100, 36)];
		[b setBackgroundImage:bimage[0] forState:UIControlStateNormal];
		[b setBackgroundImage:bimage[1] forState:UIControlStateHighlighted];
		[b addTarget:self action:@selector(replyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];
	}
	{
		UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		[b setFrame:CGRectMake(13+100, y, 97, 36)];
		[b setBackgroundImage:[self favButtonImage] forState:UIControlStateNormal];
		[b setBackgroundImage:bimage[2] forState:UIControlStateHighlighted];
		[b addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];
		favButton = [b retain];
		
		UIActivityIndicatorView *ai = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(97/2-12, 36/2-12, 24, 24)] autorelease];
		ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		ai.hidesWhenStopped = YES;
		favAI = [ai retain];
	}
	{
		UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		[b setFrame:CGRectMake(13+100+97, y, 100, 36)];
		[b setBackgroundImage:bimage[3] forState:UIControlStateNormal];
		[b setBackgroundImage:bimage[4] forState:UIControlStateHighlighted];
		[b addTarget:self action:@selector(retweetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
//	cell.cellType = CellTypeNoRound;
//	cell.bgcolor = [[Colors instance] oddBackground];
	return cell;
}

- (UITableViewCell *)urlCell:(URLPair*)pair isEven:(BOOL)isEven {	
	IconTextCell *cell = [[[IconTextCell alloc] initWithFrame:CGRectZero] autorelease];
	UIImage *icon = nil;
	if (pair.screenName || pair.conversation) {
		icon = [[Images sharedInstance] iconConversation];
	} else if (pair.url != nil) {
		icon = [[Images sharedInstance] iconURL];
	} else {
		icon = [[Images sharedInstance] iconChat];
	}
	[cell createCellWithText:pair.text icon:icon isEven:isEven];
	return cell;
}

- (void)parseToken {
	NSString *text = message.text;
	NSArray *a;

	a = [text gtm_allSubstringsMatchedByPattern:@"@[[:alnum:]_]+"];
	for (NSString *s in a) {
		URLPair *pair = [[URLPair alloc] init];
		pair.text = [NSString stringWithFormat:@"%@ + %@", message.screenName, [s substringFromIndex:1]];
		pair.screenName = [s substringFromIndex:1];
		[links addObject:pair];
		[pair release];
	}

	a = [text gtm_allSubstringsMatchedByPattern:@"http:\\/\\/[^[:space:]]+"];
	for (NSString *s in a) {
		URLPair *pair = [[URLPair alloc] init];
		pair.text = s;
		pair.url = s;
		[links addObject:pair];
		[pair release];
	}

	a = [text gtm_allSubstringsMatchedByPattern:@"https:\\/\\/[^[:space:]]+"];
	for (NSString *s in a) {
		URLPair *pair = [[URLPair alloc] init];
		pair.text = s;
		pair.url = s;
		[links addObject:pair];
		[pair release];
	}
/*
	a = [text gtm_allSubstringsMatchedByPattern:@"#[^[:space:]]+"];
	for (NSString *s in a) {
		NSLog(@"hashtags: %@", s);
	}
*/	
}

- (void)twitterClientSucceeded:(TwitterClient*)sender messages:(NSArray*)messages {
	message.favorited = !message.favorited;
	[favButton setBackgroundImage:[self favButtonImage] forState:UIControlStateNormal];
	[favAI stopAnimating];
	[favAI removeFromSuperview];
}

- (void)twitterClientFailed:(TwitterClient*)sender {
	[favButton setBackgroundImage:[self favButtonImage] forState:UIControlStateNormal];
	[favAI stopAnimating];
	[favAI removeFromSuperview];
}

- (void)twitterClientBegin:(TwitterClient*)sender {
	LOG(@"TweetView#twitterClientBegin");
}

- (void)twitterClientEnd:(TwitterClient*)sender {
	LOG(@"TweetView#twitterClientEnd");
}

@end



