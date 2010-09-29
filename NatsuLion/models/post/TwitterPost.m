#import "TwitterPost.h"
#import "ShardInstance.h"
#import "Cache.h"
#import "Account.h"
#import "GTMRegex.h"
#import "HttpClientPool.h"

static TwitterPost* shardInstance;

@implementation TwitterPost

SHARD_INSTANCE_IMPL

@synthesize replyMessage;

- (id)init {
	if (self = [super init]) {
		backupFilename = [[[Cache createTextCacheDirectory] 
						   stringByAppendingString:@"postbackup.txt"] retain];
		
		NSData *d = [Cache loadWithFilename:backupFilename];
		if (d) {
			text = [[[[NSString alloc] initWithData:d 
										   encoding:NSUTF8StringEncoding] autorelease] retain];
		}
	}
	return self;
}

- (void)createReplyPost:(NSString*)reply_to withReplyMessage:(Message*)message {
	[replyMessage release];
	replyMessage = [message retain];
	NSString *adding = [reply_to stringByAppendingString:@" "];
	if (text && [text length] > 0) {
		[self updateText:[text stringByAppendingString:adding]];
	} else {
		[self updateText:adding];
	}
}

- (void)createDMPost:(NSString*)reply_to withReplyMessage:(Message*)message {
	[replyMessage release];
	replyMessage = [message retain];
	[self updateText:[NSString stringWithFormat:@"d %@ ", reply_to]];
}

- (BOOL)isDirectMessage {
	GTMRegex *regex = [GTMRegex regexWithPattern:@"^(d[[:space:]]).*" 
										 options:kGTMRegexOptionIgnoreCase];
	return [regex matchesString:text];
}

- (BOOL)isValidInReplyToScreenName:(NSString*)screenName {
	NSString *pattern = [NSString stringWithFormat:@"^(@%@[[:space:]]).*", screenName];
	GTMRegex *regex = [GTMRegex regexWithPattern:pattern 
										 options:kGTMRegexOptionSupressNewlineSupport];	
	return [regex matchesString:text];
}

- (void)post {
	TwitterClient *tc = [[HttpClientPool sharedInstance] 
							 idleClientWithType:HttpClientPoolClientType_TwitterClient];
	tc.delegate = self;
	if (text.length > 0) {
		NSString *footer = [[Account sharedInstance] footer];
		if (footer && footer.length > 0 && ! [self isDirectMessage]) {
			[tc post:[NSString stringWithFormat:@"%@ %@", text, footer] reply_id:replyMessage.statusId];
		} else {
			[tc post:text reply_id:replyMessage.statusId];
		}
	}	
}

- (void)backupText {
	[Cache saveWithFilename:backupFilename 
						   data:[text dataUsingEncoding:NSUTF8StringEncoding]];
//	NSLog(@"saved.");
}

- (void)updateText:(NSString*)aText {
	[text release];
	text = [aText retain];
	if (text.length == 0) {
		[replyMessage release];
		replyMessage = nil;
	}
	if (replyMessage) {
		if (! [self isValidInReplyToScreenName:replyMessage.screenName] && ![self isDirectMessage]) {
			[replyMessage release];
			replyMessage = nil;
		}
	}

	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(backupText) object:nil];
	[self performSelector:@selector(backupText) withObject:nil afterDelay:1.5];
}

- (NSString*)text {
	return text;
}

- (void)dealloc {
	[text release];
	[backupFilename release];
	[replyMessage release];
	[super dealloc];
}

- (void)twitterClientSucceeded:(TwitterClient*)sender messages:(NSArray*)statuses {	
	[self updateText:@""];
}

- (void)twitterClientFailed:(TwitterClient*)sender {
}

- (void)twitterClientBegin:(TwitterClient*)sender {
	LOG(@"TweetPostView#twitterClientBegin");
}

- (void)twitterClientEnd:(TwitterClient*)sender {
	LOG(@"TweetPostView#twitterClientEnd");
}


@end
