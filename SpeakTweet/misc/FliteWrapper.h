//
//  FliteWrapper.h
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import <VKController.h>
#import <VKFliteSpeaker.h>

@interface FliteWrapper : NSObject <AVAudioPlayerDelegate> {
	AVAudioPlayer* audioPlayer;
	id onFinishPlayingDelegate;
	SEL onFinishPlayingSelector;
	VKFliteSpeaker *vkSpeaker;
}

// Use these:
//ST: added another initialization method ought to handle to "on finish playing" event
-(id)initWithOnFinishDelegate:(id)delegate 
	whenFinishPlayingExecute:(SEL)selector; 
-(void)speakText:(NSString *)text;
-(void)stopTalking;
-(void)setPitch:(float)pitch variance:(float)variance speed:(float)speed;
-(void)setVoice:(NSString *)voicename;
-(void)setVolume:(float)level;
@end