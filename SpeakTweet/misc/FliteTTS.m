//
//  FliteTTS.m
//  iPhone Text To Speech based on Flite
//
//  Copyright (c) 2010 Sam Foster
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
//  Author: Sam Foster <samfoster@gmail.com> <http://cmang.org>
//  Copyright 2010. All rights reserved.
//

#import "FliteTTS.h"

static int test = 0;
static float volumeLevel = 0.5;

@implementation FliteTTS

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

-(void)speakText:(NSString *)text
{
	NSMutableString *cleanString;
	cleanString = [NSMutableString stringWithString:@""];
	if([text length] > 1)
	{
		int x = 0;
		while (x < [text length])
		{
			unichar ch = [text characterAtIndex:x];
			[cleanString appendFormat:@"%c", ch];
			x++;
		}
	}
	if(cleanString == nil)
	{	// string is empty
		cleanString = [NSMutableString stringWithString:@""];
	}
	
	
	NSString *file = [NSString stringWithFormat:@"%@/test.wav", 
					  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
	
	
	NSLog(@"Speakers = %@", [vkSpeaker speakers]);
	[vkSpeaker speakText:cleanString toFile:file];
	
	NSURL *url = [NSURL fileURLWithPath:file];
	
    NSError *error;
	
    [audioPlayer stop];
	audioPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	[audioPlayer setDelegate:self];
	[audioPlayer setVolume:volumeLevel];
	//[audioPlayer prepareToPlay];
	[audioPlayer play];
	// Remove file
	[[NSFileManager defaultManager] removeItemAtURL:url error:nil];

}


-(void)setVolume:(float)level
{
	volumeLevel = level;
}
-(void)setPitch:(float)pitch variance:(float)variance speed:(float)speed
{
	
}

-(void)setVoice:(NSString *)voicename
{

	if([voicename isEqualToString:@"man"]) {
		[vkSpeaker setSpeaker:(NSString*)[[vkSpeaker speakers] objectAtIndex:0]];
		//voice = register_cmu_us_awb();
	}
	else if([voicename isEqualToString:@"woman"]) {
		[vkSpeaker setSpeaker:(NSString*)[[vkSpeaker speakers] objectAtIndex:0]];
		//voice = register_cmu_us_slt();
	}
}

-(void)stopTalking
{
	[audioPlayer stop];
}

-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer*)audioPlayer successfully: (BOOL)flag
{
	[onFinishPlayingDelegate performSelector:onFinishPlayingSelector];
	NSLog(@"Finished");
}

@end
