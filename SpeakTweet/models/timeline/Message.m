#import "Message.h"
#import "Account.h"
#import "IconRepository.h"

@implementation Message

@synthesize statusId, name, screenName, text, timestamp, replyType, status, user, source, 
	in_reply_to_status_id, favorited, iconContainer;
@synthesize in_reply_to_screen_name;


- (void)encodeWithCoder:(NSCoder*)coder {
	[coder encodeObject:statusId forKey:@"statusId"];
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:screenName forKey:@"screenName"];
	[coder encodeObject:text forKey:@"text"];
	[coder encodeObject:timestamp forKey:@"timestamp"];
	[coder encodeObject:source forKey:@"source"];
	[coder encodeObject:in_reply_to_status_id forKey:@"in_reply_to_status_id"];
	[coder encodeObject:in_reply_to_screen_name forKey:@"in_reply_to_screen_name"];

	[coder encodeInt:replyType forKey:@"replyType"];
	[coder encodeInt:status forKey:@"status"];
	
	[coder encodeBool:favorited forKey:@"favorited"];

	//	[coder encodeObject:user forKey:@"user"];
	//	[coder encodeObject:iconContainer forKey:@"iconContainer"];

	[coder encodeObject:iconContainer.url forKey:@"iconURL"];
	
	
	LOG(@"*** Message save status:%d", status);

}

- (id)initWithCoder:(NSCoder*)decoder {
	if (self = [super init]) {
		statusId				= [[decoder decodeObjectForKey:@"statusId"] retain];
		name					= [[decoder decodeObjectForKey:@"name"] retain];
		screenName				= [[decoder decodeObjectForKey:@"screenName"] retain];
		text					= [[decoder decodeObjectForKey:@"text"] retain];
		timestamp				= [[decoder decodeObjectForKey:@"timestamp"] retain];
		source					= [[decoder decodeObjectForKey:@"source"] retain];
		in_reply_to_status_id	= [[decoder decodeObjectForKey:@"in_reply_to_status_id"] retain];
		in_reply_to_screen_name	= [[decoder decodeObjectForKey:@"in_reply_to_screen_name"] retain];

		replyType				= [decoder decodeIntForKey:@"replyType"];
		status					= [decoder decodeIntForKey:@"status"];
		
		LOG(@"*** Message load status:%d", status);
		
		favorited				= [decoder decodeBoolForKey:@"favorited"];
		
		NSString *iconURL		= [decoder decodeObjectForKey:@"iconURL"];
		if (iconURL) {
			iconContainer		= [[[IconRepository instance] iconContainerForURL:iconURL] retain];
		}
	}
	return self;
}

- (void) dealloc {
   [statusId release];
   [name release];
   [screenName release];
   [text release];
   [timestamp release];
	[source release];
	[in_reply_to_status_id release];
	[in_reply_to_screen_name release];
	[iconContainer release];
   [super dealloc];
}

- (BOOL) isEqual:(id)anObject {
    if ([[self statusId] isEqual:[anObject statusId]]) {
        return TRUE;
    }
    return FALSE;
}

- (void) setStatus:(enum MessageStatus)value {
    status = value;
}

- (BOOL) isReplyToMe {
    if ([text hasPrefix:[@"@" stringByAppendingString:[[Account sharedInstance] screenName]]]) {
        return TRUE;
    }
    return FALSE;
}

- (BOOL) isProbablyReplyToMe {
    NSString *query = [@"@" stringByAppendingString:[[Account sharedInstance] screenName]];
    NSRange range = [text rangeOfString:query];
    
    if (range.location != NSNotFound) {
        return TRUE;
    }
    return FALSE;
}

- (BOOL) isMyUpdate {
    return [screenName isEqualToString:[[Account sharedInstance] screenName]];
}

- (void) finishedToSetProperties:(BOOL)forDirectMessage {
	if (forDirectMessage) {
		replyType = _MESSAGE_REPLY_TYPE_DIRECT;
	} else {
		/*if ([self isMyUpdate]) {
			replyType = _MESSAGE_REPLY_TYPE_MYUPDATE;
		} else*/ if ([self isReplyToMe]) {
			replyType = _MESSAGE_REPLY_TYPE_REPLY;
		} else if ([self isProbablyReplyToMe]) {
			replyType = _MESSAGE_REPLY_TYPE_REPLY_PROBABLE;
		} else {
			replyType = _MESSAGE_REPLY_TYPE_NORMAL;
		}
	}
}

- (void) hilightUserReplyWithScreenName:(NSString*)aScreenName {
	NSString *query = [@"@" stringByAppendingString:aScreenName];
	NSRange range = [text rangeOfString:query];
	
	if (range.location != NSNotFound) {
		replyType = _MESSAGE_REPLY_TYPE_REPLY_PROBABLE;
	}
}

- (void) setIconForURL:(NSString*)url {
	[iconContainer release];
	IconContainer *container = [[IconRepository instance] iconContainerForURL:url];
	iconContainer = [container retain];
}

- (NSString*) messageToSay {
	
	// this parsing function is a mess, seriously, wrap an url in a mess
	// Cocoa is not good with this kind of stuff, a lot of code wasted 
	// with NSRange and NSString to search for URLs inside a string...
	
	// fortunately I've found RegexKitLite .h and .m (added to misc folder)
	// also needed to add "-licucore" in "Other linker Flags" property in target info  (it took a lot of time)

	NSString* regexToDelete = @"http[A-Za-z0-9!#$%&'()*+,./:;<=>?@^_`{|}~-]*";
	NSString* textPurged;
	
	//removing URLs
	textPurged = [text stringByReplacingOccurrencesOfRegex:regexToDelete
															  withString:@" reference to U R L "];
	
	regexToDelete = @":P|:-P|;P|;-P|:p|:-p|;p|;-p|:D|:-D|;D|;-D|xd|XD|xD|o_O|O_o|O_O|[*_*]*";
	
	//removing smiles
	textPurged = [textPurged stringByReplacingOccurrencesOfRegex:regexToDelete
															  withString:@""];
	
	//removing mention symbols
	textPurged = [textPurged stringByReplacingOccurrencesOfString:@"@"
																		withString:@" mention to "];
	
	//removing hash tags symbols
	textPurged = [textPurged stringByReplacingOccurrencesOfString:@"#"
																		withString:@" hash tag for "];
	
	NSString* messageToSay = [NSString stringWithFormat:@"%@ says %@", name, textPurged];
	
	return messageToSay;
	
}

@end
