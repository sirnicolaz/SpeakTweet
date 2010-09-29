#import "Status.h"
#import "StatusCell.h"

#define SCROLLPOS_INIT_VALUE	(-10000)

@implementation Status
@synthesize message, textHeight, cellHeight;

- (void)encodeWithCoder:(NSCoder*)coder {
	[coder encodeFloat:cellHeight forKey:@"cellHeight"];
	[coder encodeFloat:textHeight forKey:@"textHeight"];
	[coder encodeObject:message forKey:@"message"];	
}

- (id)initWithCoder:(NSCoder*)decoder {
	if (self = [super init]) {
		cellHeight	= [decoder decodeFloatForKey:@"cellHeight"];
		textHeight	= [decoder decodeFloatForKey:@"textHeight"];
		message		= [[decoder decodeObjectForKey:@"message"] retain];
	}
	return self;
}

- (Status*)initWithMessage:(Message*)msg {
	if (self = [super init]) {
		message = msg;
		[message retain];
		[self setTextHeight:[StatusCell getTextboxHeight:msg.text]];
	}
	return self;
}

- (void)dealloc {
	[message release];
	[super dealloc];
}

- (BOOL)isEqual:(Status*)anObject {
	return [self.message isEqual:anObject.message];
}

- (void)setTextHeight:(CGFloat)height {
	textHeight = height;
	height += 24;
	if (height < 52) height = 52;
	cellHeight = height;
}

- (BOOL)markAsRead {
	if (message.status == _MESSAGE_STATUS_NORMAL) {
		message.status = _MESSAGE_STATUS_READ;
		return YES;
	}
	return NO;
}

- (int)updateReadTrackCounter:(int)continueCounter {
	if (continueCounter == readTrackContinueCounter + 1) {
		readTrackCounter++;
	} else {
		readTrackCounter = 0;
	}
	readTrackContinueCounter = continueCounter;
	return readTrackCounter;
}


@end
