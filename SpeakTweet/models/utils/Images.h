#import <UIKit/UIKit.h>

@interface Images : NSObject {
	UIImage *unreadDark;
	//UIImage *unreadLight;
	UIImage *starHilighted;

	UIImage *iconChat;
	UIImage *iconConversation;
	UIImage *iconURL;
	UIImage *iconSafari;
}

+ (id) sharedInstance;

@property (readonly) UIImage *unreadDark, *starHilighted; //*unreadLight

@property (readonly) UIImage *iconChat;
@property (readonly) UIImage *iconConversation;
@property (readonly) UIImage *iconURL;
@property (readonly) UIImage *iconSafari;

@end
