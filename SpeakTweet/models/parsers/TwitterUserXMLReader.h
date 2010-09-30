#import <UIKit/UIKit.h>
#import "User.h"

@interface TwitterUserXMLReader : NSObject {
	NSMutableString *currentStringValue;
	BOOL userTagChild;
	BOOL readText;

	NSMutableArray *users;
	User *user;
}

- (void)parseXMLData:(NSData *)data;

@property (readonly) NSMutableArray *users;

@end
