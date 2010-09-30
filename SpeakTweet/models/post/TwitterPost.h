#import <Foundation/Foundation.h>
#import "TwitterClient.h"
#import "Message.h"

@interface TwitterPost : NSObject<TwitterClientDelegate> {
	NSString *text;
	NSString *backupFilename;
	Message *replyMessage; 
}

@property (readonly) Message *replyMessage; 

+ (id)shardInstance;

- (void)updateText:(NSString*)text;
- (void)post;

- (void)createReplyPost:(NSString*)reply_to withReplyMessage:(Message*)message;
- (void)createDMPost:(NSString*)reply_to withReplyMessage:(Message*)message;

- (NSString*)text;

- (BOOL)isDirectMessage;

- (void)backupText;


@end
