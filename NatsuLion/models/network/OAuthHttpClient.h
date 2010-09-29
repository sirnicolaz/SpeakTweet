#ifdef ENABLE_OAUTH
#import "HttpClient.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "OAConsumer.h"

@interface OAuthHttpClient : HttpClient {
	OAHMAC_SHA1SignatureProvider *signatureProvider;
	OAConsumer *consumer;
}

@end

#endif