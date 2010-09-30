#import <UIKit/UIKit.h>

@interface XMLHTTPEncoder : NSObject {
}

+ (NSString*) decodeXML:(NSString*)aString;
+ (NSString*) encodeHTTP:(NSString*)aString;

@end
