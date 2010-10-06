//
//  FliteWrapper.m
//  Text To Speech wrapper based on Flite
//
//  Copyright (c) 2010 Nicola Miotto, Alberto De Bortoli
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
//

#import "FliteWrapper.h"

static float volumeLevel = 0.5;

@implementation FliteWrapper

-(id)init
{
    self = [super init];
	
	vkSpeaker = [[VKFliteSpeaker alloc] init];
	
	[self setVoice:@"man"];
    return self;
}

-(id)initWithOnFinishDelegate:(id)delegate 
	   whenFinishPlayingExecute:(SEL)selector{
	
	self = [self init];
	onFinishPlayingDelegate = delegate;
	onFinishPlayingSelector = selector;

	return self;
};

-(void)speakText:(NSURL *)url
{	
	
	NSError *error;
	
	[audioPlayer stop];
	[audioPlayer release];

	audioPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	[audioPlayer setDelegate:self];
	[audioPlayer setVolume:volumeLevel];
	[audioPlayer prepareToPlay];
	[audioPlayer play];
	// Remove file
	[[NSFileManager defaultManager] removeItemAtURL:url error:nil];

}

-(NSURL *)synthesize:(NSString *)text
			  withPitch:(float)pitch
		  withVariance:(float)variance
			  withSpeed:(float)speed
{
	NSString *file = [NSString stringWithFormat:@"%@/spokenTweet.wav", 
					  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
	
	NSLog(@"Speakers = %@", [vkSpeaker speakers]);
	[vkSpeaker speakText:text
					  toFile:file
				  withPitch:pitch
			  withVariance:variance
				  withSpeed:speed];
	
	NSURL *url = [NSURL fileURLWithPath:file];
	
	return url;
	
}


-(void)setVolume:(float)level {
	
	volumeLevel = level;
}


-(void)setPitch:(float)pitch variance:(float)variance speed:(float)speed {
	[vkSpeaker setPitch:pitch variance:variance speed:speed];
}

-(void)setVoice:(NSString *)voicename {

	if([voicename isEqualToString:@"man"]) {
		//[vkSpeaker setSpeaker:(NSString*)[[vkSpeaker speakers] objectAtIndex:0]];
		[vkSpeaker setSpeaker:@"man"];
		//voice = register_cmu_us_awb();
	}
	else if([voicename isEqualToString:@"woman"]) {
		//[vkSpeaker setSpeaker:(NSString*)[[vkSpeaker speakers] objectAtIndex:0]];
		[vkSpeaker setSpeaker:@"woman"];
		//voice = register_cmu_us_slt();
	}
}


-(void)stopTalking {
	[audioPlayer stop];
}


-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer*)audioPlayer successfully: (BOOL)flag {
	[onFinishPlayingDelegate performSelector:onFinishPlayingSelector];
	NSLog(@"Finished");
}

@end
