#import "TweetPostViewController.h"
#import "AppDelegate.h"
#import "Account.h"
#import "Cache.h"
#import "Configuration.h"
#import "TwitterPost.h"

@interface TweetPostViewController(Private)
- (IBAction)closeButtonPushed:(id)sender;
- (IBAction)sendButtonPushed:(id)sender;
- (IBAction)clearButtonPushed:(id)sender;

@end

static TweetPostViewController *_tweetViewController;

@implementation TweetPostViewController

+ (BOOL)active {
	return _tweetViewController ? YES : NO;
}

+ (void)dismiss {
	[_tweetViewController dismissModalViewControllerAnimated:NO];
	[_tweetViewController release];
	_tweetViewController = nil;
}

+ (void)present:(UIViewController*)parentViewController {
	[TweetPostViewController dismiss];
	TweetPostViewController *vc = [[[TweetPostViewController alloc] init] autorelease];
	[parentViewController presentModalViewController:vc animated:NO];
	_tweetViewController = [vc retain];
}

- (void)updateViewColors {
	UIColor *textColor, *backgroundColor, *backgroundColorBottom;
	//if ([[Configuration instance] darkColorTheme]) {
		textColor = [UIColor whiteColor];
		if ([[TwitterPost shardInstance] isDirectMessage]) {
			backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.5f alpha:1.f];
		} else {
			backgroundColor = [UIColor colorWithWhite:61.f/255.f alpha:1.0f];
		}
		backgroundColorBottom = [UIColor colorWithWhite:24.f/255.f alpha:1.0f];
	/*} else {
		textColor = [UIColor blackColor];
		if ([[TwitterPost shardInstance] isDirectMessage]) {
			backgroundColor = [UIColor colorWithRed:0.8f green:0.8f blue:1.f alpha:1.f];
		} else {
			backgroundColor = [UIColor colorWithWhite:252.f/255.f alpha:1.0f];
		}
		backgroundColorBottom = [UIColor colorWithWhite:200.f/255.f alpha:1.0f];
	}*/
	
	self.view.backgroundColor = backgroundColorBottom;//[UIColor blackColor];
	
	tweetPostView.textView.textColor = textColor;
	tweetPostView.textView.backgroundColor = backgroundColor;
	
	if ([[TwitterPost shardInstance] replyMessage]) {
		tweetPostView.backgroundColor = backgroundColorBottom;
	} else {
		tweetPostView.backgroundColor = backgroundColor;
	}
	
	//if ([[Configuration instance] darkColorTheme]) {
		// to use black keyboard appearance
		tweetPostView.textView.keyboardAppearance = UIKeyboardAppearanceAlert;
	/*} else {
		// to use default keyboard appearance
		tweetPostView.textView.keyboardAppearance = UIKeyboardAppearanceDefault;
	}*/
}

- (void)setupViews {

	self.view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
	
	UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
	toolbar.barStyle = UIBarStyleBlackOpaque;

	UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] 
									initWithTitle:@"close" 
									style:UIBarButtonItemStyleBordered 
									target:self action:@selector(closeButtonPushed:)] autorelease];
	
	UIBarButtonItem *clearButton = [[[UIBarButtonItem alloc] 
									initWithTitle:@"clear" 
									style:UIBarButtonItemStyleBordered 
									target:self action:@selector(clearButtonPushed:)] autorelease];
	
	UIView *expandView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 133, 44)] autorelease];

	textLengthView = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 133-80, 34)];
	textLengthView.font = [UIFont boldSystemFontOfSize:20];
	textLengthView.textAlignment = UITextAlignmentRight;
	textLengthView.textColor = [UIColor whiteColor];
	textLengthView.backgroundColor = [UIColor clearColor];
	textLengthView.text = @"140";
	
	[expandView addSubview:textLengthView];
	
	UIBarButtonItem	*expand = [[[UIBarButtonItem alloc] initWithCustomView:expandView] autorelease];
	
	UIBarButtonItem *sendButton = [[[UIBarButtonItem alloc] 
									initWithTitle:@"post" 
									style:UIBarButtonItemStyleBordered 
									target:self action:@selector(sendButtonPushed:)] autorelease];
	
	[toolbar setItems:[NSArray arrayWithObjects:closeButton, clearButton, expand, sendButton, nil]];
	
	
	tweetPostView = [[TweetPostView alloc] initWithFrame:CGRectMake(0, 44, 320, 200)];
	tweetPostView.textViewDelegate = self;
		
	[self.view addSubview:toolbar];
	[self.view addSubview:tweetPostView];
	[self updateViewColors];
}

- (void)setMaxTextLength {
	maxTextLength = 140;
	NSString *footer = [[Account sharedInstance] footer];
	if (footer && [footer length] > 0 && 
		! [[TwitterPost shardInstance] isDirectMessage]) {
		maxTextLength -= [footer length] + 1;
	}
}

- (void)updateTextLengthView {
	[self setMaxTextLength];
	int len = [tweetPostView.textView.text length];
	[textLengthView setText:[NSString stringWithFormat:@"%d", (maxTextLength-len)]];
	if (len >= maxTextLength) {
		textLengthView.textColor = [UIColor redColor];
	} else {
		textLengthView.textColor = [UIColor whiteColor];
	}	
}

- (void)viewDidLoad {
	[self setMaxTextLength];
	[self setupViews];
	[self updateTextLengthView];
	[super viewDidLoad];
}

- (void)dealloc {
	LOG(@"TweetPostViewController dealloc");
	[tweetPostView release];
	[textLengthView release];
	[super dealloc];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	return YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[self updateViewColors];
	tweetPostView.textView.text = [[TwitterPost shardInstance] text];
	[tweetPostView.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[tweetPostView.textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
	[[TwitterPost shardInstance] updateText:tweetPostView.textView.text];
	[self updateTextLengthView];
	[self updateViewColors];
	[tweetPostView updateQuoteView];
}

- (IBAction)closeButtonPushed:(id)sender {
	[tweetPostView.textView resignFirstResponder];
	[TweetPostViewController dismiss];
}

- (IBAction)clearButtonPushed:(id)sender {
	tweetPostView.textView.text = @""; // this will invoke textViewDidChange
}

- (IBAction)sendButtonPushed:(id)sender {
	[[TwitterPost shardInstance] updateText:tweetPostView.textView.text];
	[[TwitterPost shardInstance] post];
	
	[tweetPostView.textView resignFirstResponder];
	[TweetPostViewController dismiss];
}

@end
