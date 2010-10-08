//
//  VKFliteSpeaker.h
//  VocalKit
//
//  Created by Brian King on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "flite.h"


@interface VKFliteSpeaker : NSObject {
	cst_voice *desired_voice;
	cst_features *feature_config;
	cst_val *voice_list;
	cst_audio_streaming_info *asi;

	
}


- (NSArray*) speakers;
- (void) setSpeaker:(NSString*)speakerName;
- (void) speakText:(NSString*)text
				toFile:(NSString*)filename
			withPitch:(float)pitch
		withVariance:(float)variance
			withSpeed:(float)speed;

- (void)setPitch:(float)pitch variance:(float)variance speed:(float)speed;

- (void) setIntegerValue:(int)iValue forKey:(NSString*)key;
- (void) setFloatValue:(float)fValue forKey:(NSString*)key;
- (void) setStringValue:(NSString*)string forKey:(NSString*)key;




@end
