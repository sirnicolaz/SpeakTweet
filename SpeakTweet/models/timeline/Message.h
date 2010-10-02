#import <UIKit/UIKit.h>
#import "User.h"
#import "IconRepository.h"
#import "RegexKitLite.h"


enum ReplyType {
    _MESSAGE_REPLY_TYPE_NORMAL = 0,
    _MESSAGE_REPLY_TYPE_DIRECT,
    _MESSAGE_REPLY_TYPE_REPLY,
    _MESSAGE_REPLY_TYPE_REPLY_PROBABLE,
    _MESSAGE_REPLY_TYPE_MYUPDATE,
};

enum MessageStatus {
    _MESSAGE_STATUS_NORMAL = 0,
    _MESSAGE_STATUS_READ,
};

@class Message;

@interface Message : NSObject {
   NSString *statusId;
   NSString *name;
   NSString *screenName;
	NSString *text;
	NSString *source;
	NSString *in_reply_to_status_id;
	NSString *in_reply_to_screen_name;
   NSDate *timestamp;
   enum ReplyType replyType;
   enum MessageStatus status;
   User *user;
	BOOL favorited;
	IconContainer *iconContainer;
}

@property(readwrite, copy) NSString *statusId, *name, *screenName, *text, *source, *in_reply_to_status_id;
@property(readwrite, copy) NSString *in_reply_to_screen_name;
@property(readwrite, retain) NSDate *timestamp;
@property(readwrite) enum ReplyType replyType;
@property(readwrite) enum MessageStatus status;
@property(readwrite, retain) User *user;
@property(readonly) IconContainer *iconContainer;
@property BOOL favorited;

- (BOOL) isEqual:(id)anObject;
- (void) finishedToSetProperties:(BOOL)forDirectMessage;
- (void) hilightUserReplyWithScreenName:(NSString*)screenName;
- (void) setIconForURL:(NSString*)url;
- (NSString*) messageToSay;
@end
