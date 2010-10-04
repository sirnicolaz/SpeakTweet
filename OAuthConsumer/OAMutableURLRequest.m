//
//  OAMutableURLRequest.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 10/19/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "OAMutableURLRequest.h"


@interface OAMutableURLRequest (Private)
- (void)_generateTimestamp;
- (void)_generateNonce;
- (NSString *)_signatureBaseString;
@end

@implementation OAMutableURLRequest
@synthesize signature, nonce;

#pragma mark init

- (id)initWithURL:(NSURL *)aUrl
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider
{
    if (self = [super initWithURL:aUrl
					  cachePolicy:NSURLRequestReloadIgnoringCacheData
				  timeoutInterval:10.0])
	{    
		consumer = [aConsumer retain];
		
		// empty token for Unauthorized Request Token transaction
		if (aToken == nil)
			token = [[OAToken alloc] init];
		else
			token = [aToken retain];
		
		if (aRealm == nil)
			realm = [[NSString alloc] initWithString:@""];
		else 
			realm = [aRealm retain];
		
		// default to HMAC-SHA1
		if (aProvider == nil)
			signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
		else 
			signatureProvider = [aProvider retain];
		
		callback_url = @"";
		verifier = @"";
		
		[self _generateTimestamp];
		[self _generateNonce];
	}
    return self;
}

// Setting a timestamp and nonce to known
// values can be helpful for testing
- (id)initWithURL:(NSURL *)aUrl
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider
            nonce:(NSString *)aNonce
        timestamp:(NSString *)aTimestamp 
{
	if (self = [super initWithURL:aUrl
					  cachePolicy:NSURLRequestReloadIgnoringCacheData
				  timeoutInterval:10.0])
	{    
		consumer = [aConsumer retain];
		
		// empty token for Unauthorized Request Token transaction
		if (aToken == nil)
			token = [[OAToken alloc] init];
		else
			token = [aToken retain];
		
		if (aRealm == nil)
			realm = [[NSString alloc] initWithString:@""];
		else 
			realm = [aRealm retain];
		
		// default to HMAC-SHA1
		if (aProvider == nil)
			signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
		else 
			signatureProvider = [aProvider retain];
		
		callback_url = @"";
		verifier = @"";
		
		timestamp = [aTimestamp retain];
		nonce = [aNonce retain];
	}
    return self;
}

- (void)setCallbackURL:(NSString *)url
{
	//ST: Setting the callback url
	callback_url = [url retain];
	
}

- (void)setVerifier:(NSString *)aVerifier
{
	//ST: setting the verifier
	NSLog(@"Setting verifier");
	verifier = [aVerifier retain];
}	

- (void)dealloc
{
	[consumer release];
	[token release];
	[realm release];
	[signatureProvider release];
	[timestamp release];
	[nonce release];
	[callback_url release];
	[super dealloc];
}

#pragma mark -
#pragma mark Public

- (void)prepare 
{
    // sign
	// Secrets must be urlencoded before concatenated with '&'
	// TODO: if later RSA-SHA1 support is added then a little code redesign is needed
	NSString *signatureBaseString = [self _signatureBaseString];
	NSLog(@"Signature base %@", signatureBaseString);
    signature = [signatureProvider signClearText:signatureBaseString
                                      withSecret:[NSString stringWithFormat:@"%@&%@",
												  [consumer.secret URLEncodedString],
                                                  [token.secret URLEncodedString]]];
    
	NSLog(@"Signature %@", signature);
    // set OAuth headers
    NSString *oauthToken;
    if ([token.key isEqualToString:@""])
        oauthToken = @""; // not used on Request Token transactions
    else
        oauthToken = [NSString stringWithFormat:@"oauth_token=\"%@\", ", [token.key URLEncodedString]];
	
	NSString *oauthCallback;
	//ST: set verifier if exists
	if ([callback_url isEqualToString:@""])
		oauthCallback = @"";
	else 
		oauthCallback = [NSString stringWithFormat:@"oauth_callback=\"%@\", ", [callback_url URLEncodedString]];
	
	
	NSString *oauthVerifier;
	//ST: set verifier if exists
	if ([verifier isEqualToString:@""])
		oauthVerifier = @"";
	else 
		oauthVerifier = [NSString stringWithFormat:@"oauth_verifier=\"%@\", ", [verifier URLEncodedString]];
	
	 //ST: set the request string including the oauth_callback parameter
	 NSString *oauthHeader = [NSString stringWithFormat:@"OAuth %@oauth_consumer_key=\"%@\", %@oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_timestamp=\"%@\", oauth_nonce=\"%@\", %@oauth_version=\"1.0\"",
								 oauthCallback,
								 [consumer.key URLEncodedString],
								 oauthToken,
								 [[signatureProvider name] URLEncodedString],
					             [signature URLEncodedString],
								 timestamp,
								 nonce,
								 oauthVerifier];


	NSLog(@"Auth header %@", oauthHeader);
	
    [self setValue:oauthHeader forHTTPHeaderField:@"Authorization"];
}

#pragma mark -
#pragma mark Private

- (void)_generateTimestamp 
{
    timestamp = [[NSString stringWithFormat:@"%d", time(NULL)] retain];
}

- (void)_generateNonce 
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSMakeCollectable(theUUID);
    nonce = (NSString *)string;
}

- (NSString *)_signatureBaseString 
{
    // OAuth Spec, Section 9.1.1 "Normalize Request Parameters"
    // build a sorted array of both request parameters and OAuth header parameters
	
	//ST: set the amount of parameters. If the callback url is set, there is 1 parameter more.
	int parametersAmount = 6;
	if (callback_url != @"") {
		parametersAmount++;
	}
	if (verifier != @"") {
		parametersAmount++;
	}

    NSMutableArray *parameterPairs = [NSMutableArray  arrayWithCapacity:(parametersAmount + [[self parameters] count])]; // 7 being the number of OAuth params in the Signature Base String
    
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_consumer_key" value:consumer.key] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_signature_method" value:[signatureProvider name]] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_timestamp" value:timestamp] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_nonce" value:nonce] URLEncodedNameValuePair]];
	if(callback_url != @"")
	{
		[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_callback" value:callback_url] URLEncodedNameValuePair]];
	}
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_version" value:@"1.0"] URLEncodedNameValuePair]];
    
    if (![token.key isEqualToString:@""]) {
        [parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_token" value:token.key] URLEncodedNameValuePair]];
    }
	if (![verifier isEqualToString:@""]){
		[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_verifier" value:verifier] URLEncodedNameValuePair]];
	}
    
    for (OARequestParameter *param in [self parameters]) {
        [parameterPairs addObject:[param URLEncodedNameValuePair]];
    }
    
    NSArray *sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
    NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];
    
    // OAuth Spec, Section 9.1.2 "Concatenate Request Elements"
    NSString *ret = [NSString stringWithFormat:@"%@&%@&%@",
					 [self HTTPMethod],
					 [[[self URL] URLStringWithoutQuery] URLEncodedString],
					 [normalizedRequestParameters URLEncodedString]];
	
	NSLog(@"Returned normalized URL: %@", ret);
	
	return ret;
}

@end
