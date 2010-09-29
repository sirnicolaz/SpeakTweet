#import "Message.h"
#import <libxml/tree.h>

typedef struct ParserContext {
	NSMutableData	*currentString;
	Message		*currentMessage;
	NSString		*currentIconURL;	
	NSString		*currentInReplyToUserId;
	
	BOOL statusTagChild;
	BOOL userTagChild;
	BOOL readText;
	BOOL currentMsgDirectMessage;
	
	NSMutableArray	*messages;
	
} ParserContext;

@interface TwitterXMLParser : NSObject {
	NSArray *messages;
	ParserContext ctx;
	xmlParserCtxtPtr context;
}

@property (readonly) NSArray *messages;

- (void)parseXMLData:(NSData *)data;
- (void)parseXMLDataPartial:(NSData *)data;

@end
