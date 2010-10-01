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

#import "FliteTTS_HTS.h"
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <stdarg.h>


#define INPUT_BUFF_SIZE 1024
//static const NSString *voicesDir = @"hts_voices/";
static int test = 0;
static float volumeLevel = 0.5;

//static NSString *resourceDir;

@implementation FliteTTS_HTS


//Just to know
#define HTS_ENGINE_COMMAND @"flite_hts_engine \
-td tree-dur.inf -tf tree-lf0.inf -tm tree-mgc.inf \
-md dur.pdf         -mf lf0.pdf       -mm mgc.pdf \
-df lf0.win1        -df lf0.win2      -df lf0.win3 \
-dm mgc.win1        -dm mgc.win2      -dm mgc.win3 \
-cf gv-lf0.pdf      -cm gv-mgc.pdf    -ef tree-gv-lf0.inf \
-em tree-gv-mgc.inf -k  gv-switch.inf -o  output.wav \
input.txt";


-(id)init
{
    self = [super init];
	
	// Set a default voice
	[self setDefaultVoice];
	
    return self;
}

-(NSArray*)getCommandParameters
{
	NSString *td_l = @"-td"; NSString *td_r = @"tree-dur.inf";
	NSString *tf_l = @"-tf"; NSString *tf_r = @"tree-lf0.inf";
	NSString *tm_l = @"-tm"; NSString *tm_r = @"tree-mgc.inf";
	NSString *md_l = @"-md"; NSString *md_r = @"dur.pdf";
	NSString *mf_l = @"-mf"; NSString *mf_r = @"lf0.pdf";
	NSString *mm_l = @"-mm"; NSString *mm_r = @"mgc.pdf";
	NSString *df_l = @"-df"; NSString *df1_r = @"lf0.win1";
	NSString *df2_r = @"lf0.win2";
	NSString *df3_r = @"lf0.win3";
	NSString *dm_l = @"-dm"; NSString *dm1_r = @"mgc.win1";
	NSString *dm2_r = @"mgc.win2";
	NSString *dm3_r = @"mgc.win3";
	NSString *cf_l = @"-cf"; NSString *cf_r = @"gv-lf0.pdf";
	NSString *cm_l = @"-cm"; NSString *cm_r = @"gv-mgc.pdf";
	NSString *ef_l = @"-ef"; NSString *ef_r = @"tree-gv-lf0.inf";
	NSString *em_l = @"-em"; NSString *em_r = @"tree-gv-mgc.inf";
	NSString *a_l = @"-a"; NSString *a_r = voiceAlpha;
	NSString *k_l = @"-k"  ; NSString *k_r = @"gv-switch.inf";
	
	NSArray *command = [NSArray arrayWithObjects:
						td_l,td_r,tf_l,tf_r,tm_l,tm_r,
						md_l,md_r,mf_l,mf_r,mm_l,mm_r,
						df_l,df1_r,df_l,df2_r,df_l,df3_r,
						dm_l,dm1_r,dm_l,dm2_r,dm_l,dm3_r,
						cf_l,cf_r,cm_l,cm_r,ef_l,ef_r,
						em_l,em_r,a_l,a_r,k_l,k_r,nil];
	
	return command;
}

-(void)setDefaultVoice
{
	[self setVoice:@"man"];
}

-(void)setVoice:(NSString*)voice
{
	if(voice == @"man"){
		voiceAlpha = @"0.55";
		pitch = -8.0;
	}
	else {
		voiceAlpha = @"0.45";
		pitch = 0.0;
	}
	[self setUpEngine:[self getCommandParameters]];
}

/* Getfp: wrapper for fopen */
FILE *Getfp(const char *name, const char *opt)
{
	FILE *fp = fopen(name, opt);
	
	if (fp == NULL)
		NSLog(@"Getfp: Cannot open %s.\n", name);
	
	return (fp);
}

/* Getfp: wrapper for fopen */
-(FILE*)getFilePointer:(NSString*)name option:(const char*)option 
{
	NSString *resourceDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"];	
	NSString *completePath = [resourceDir stringByAppendingString:name];
	FILE *fp = fopen((char*)[completePath UTF8String], option);
	
	if (fp == NULL)
		NSLog(@"Getfp: Cannot open %s.\n", name);
	
	return (fp);
}

-(void)setUpEngine:(NSArray*)argv 
{
	int i;
	int argc = [argv count];
	int argvSize = [argv count];
	//char buff[INPUT_BUFF_SIZE];
	/* file pointers of models */
	FILE *fp_ms_lf0 = NULL;
	FILE *fp_ms_mcp = NULL;
	FILE *fp_ms_dur = NULL;
	
	/* file pointers of trees */
	FILE *fp_ts_lf0 = NULL;
	FILE *fp_ts_mcp = NULL;
	FILE *fp_ts_dur = NULL;
	
	/* file pointers of windows */
	FILE **fp_ws_lf0;
	FILE **fp_ws_mcp;
	int num_ws_lf0 = 0, num_ws_mcp = 0;
	
	/* file pointers of global variance */
	FILE *fp_ms_gvl = NULL;
	FILE *fp_ms_gvm = NULL;
	
	/* file pointers of global variance trees */
	FILE *fp_ts_gvl = NULL;
	FILE *fp_ts_gvm = NULL;
	
	/* file pointer of global variance switch */
	FILE *fp_gv_switch = NULL;
	
	/* global parameter */
	int sampling_rate = 16000;
	int fperiod = 80;
	double alpha = 0.42;
	double stage = 0.0;          /* gamma = -1.0/stage */
	double beta = 0.0;
	int audio_buff_size = 1600;
	double uv_threshold = 0.5;
	HTS_Boolean use_log_gain = FALSE;
	double gv_weight_lf0 = 0.7;
	double gv_weight_mcp = 1.0;
	
	/* engine */
	//Flite_HTS_Engine engine;
	
	/* delta window handler for log f0 */
	fp_ws_lf0 = (FILE **) calloc(argc, sizeof(FILE *));
	/* delta window handler for mel-cepstrum */
	fp_ws_mcp = (FILE **) calloc(argc, sizeof(FILE *));
	
	int currentIndex = 0;
	/* read command */
	while (currentIndex < argvSize) {
		NSString *currentParameter = [argv objectAtIndex:currentIndex]; 
		currentIndex++;
		if ([currentParameter characterAtIndex:0] == '-') {
			char secondCharacter = [currentParameter characterAtIndex:1];
			char thirdCharacter;
			switch (secondCharacter) {
				case 't':
					thirdCharacter = [currentParameter characterAtIndex:2];
					switch (thirdCharacter) {
						case 'f':
						case 'p':
							if (fp_ts_lf0 == NULL)
								fp_ts_lf0 = [self getFilePointer:[argv objectAtIndex:currentIndex] option:"r"];
							break;
						case 'm':
							if (fp_ts_mcp == NULL)
								fp_ts_mcp = [self getFilePointer:[argv objectAtIndex:currentIndex] option:"r"];
							break;
						case 'd':
							if (fp_ts_dur == NULL)
								fp_ts_dur = [self getFilePointer:[argv objectAtIndex:currentIndex] option:"r"];
							break;
						default:
							NSLog(@"flite_hts_engine: Invalid option '-t%c'.\n",
								  thirdCharacter);
					}
					--argc;
					currentIndex++;
					break;
				case 'm':
					thirdCharacter = [currentParameter characterAtIndex:2];
					switch (thirdCharacter) {
						case 'f':
						case 'p':
							if (fp_ms_lf0 == NULL)
								fp_ms_lf0 = [self getFilePointer:[argv objectAtIndex:currentIndex] option:"rb"];
							break;
						case 'm':
							if (fp_ms_mcp == NULL)
								fp_ms_mcp = [self getFilePointer:[argv objectAtIndex:currentIndex] option:"rb"];
							break;
						case 'd':
							if (fp_ms_dur == NULL)
								fp_ms_dur = [self getFilePointer:[argv objectAtIndex:currentIndex] option:"rb"];
							break;
						default:
							NSLog(@"flite_hts_engine: Invalid option '-m%c'.\n",
								  thirdCharacter);
					}
					--argc;
					currentIndex++;
					break;
				case 'd':
					thirdCharacter = [currentParameter characterAtIndex:2];
					switch (thirdCharacter) {
						case 'f':
						case 'p':
							fp_ws_lf0[num_ws_lf0++] = [self getFilePointer:[argv objectAtIndex:currentIndex] option:"r"];
							break;
						case 'm':
							fp_ws_mcp[num_ws_mcp++] = [self getFilePointer:[argv objectAtIndex:currentIndex] option:"r"];
							break;
						default:
							NSLog(@"flite_hts_engine: Invalid option '-d%c'.\n",
								  thirdCharacter);
					}
					--argc;
					break;
				case 's':
					sampling_rate = atoi((char*)[(NSString*)[argv objectAtIndex:currentIndex] UTF8String]);
					--argc;
					currentIndex++;
					break;
				case 'p':
					fperiod = atoi((char*)[(NSString*)[argv objectAtIndex:currentIndex] UTF8String]);
					--argc;
					currentIndex++;
					break;
				case 'a':
					NSLog(@"Setting alpha %@", (NSString*)[argv objectAtIndex:currentIndex]);
					alpha = atof((char*)[(NSString*)[argv objectAtIndex:currentIndex] UTF8String]);
					--argc;
					currentIndex++;
					break;
				case 'g':
					stage = atoi((char*)[(NSString*)[argv objectAtIndex:currentIndex] UTF8String]);
					--argc;
					currentIndex++;
					break;
				case 'l':
					use_log_gain = TRUE;
					break;
				case 'b':
					beta = atof((char*)[(NSString*)[argv objectAtIndex:currentIndex] UTF8String]);
					--argc;
					currentIndex++;
					break;
				case 'u':
					uv_threshold = atof((char*)[(NSString*)[argv objectAtIndex:currentIndex] UTF8String]);
					--argc;
					currentIndex++;
					break;
				case 'e':
					thirdCharacter = [currentParameter characterAtIndex:2];
					switch (thirdCharacter) {
						case 'f':
						case 'p':
							if (fp_ts_gvl == NULL)
								fp_ts_gvl = [self getFilePointer:[argv objectAtIndex:currentIndex] option:"r"];
							break;
						case 'm':
							if (fp_ts_gvm == NULL)
								fp_ts_gvm = [self getFilePointer:[argv objectAtIndex:currentIndex] option:"r"];
							break;
						default:
							NSLog(@"flite_hts_engine: Invalid option '-e%c'.\n",
								  thirdCharacter);
					}
					--argc;
					currentIndex++;
					break;
				case 'c':
					thirdCharacter = [currentParameter characterAtIndex:2];
					switch (thirdCharacter) {
						case 'f':
						case 'p':
							if (fp_ms_gvl == NULL)
								fp_ms_gvl = [self getFilePointer:[argv objectAtIndex:currentIndex] option:"rb"];
							break;
						case 'm':
							if (fp_ms_gvm == NULL)
								fp_ms_gvm = [self getFilePointer:[argv objectAtIndex:currentIndex] option:"rb"];
							break;
						default:
							NSLog(@"flite_hts_engine: Invalid option '-c%c'.\n",
								  thirdCharacter);
					}
					--argc;
					break;
				case 'j':
					thirdCharacter = [currentParameter characterAtIndex:2];
					switch (thirdCharacter) {
						case 'f':
						case 'p':
							gv_weight_lf0 = atof((char*)[(NSString*)[argv objectAtIndex:currentIndex] UTF8String]);
							break;
						case 'm':
							gv_weight_mcp = atof((char*)[(NSString*)[argv objectAtIndex:currentIndex] UTF8String]);
							break;
						default:
							NSLog(@"flite_hts_engine: Invalid option '-j%c'.\n",
								 thirdCharacter);
					}
					--argc;
					currentIndex++;
					break;
				case 'k':
					if (fp_gv_switch == NULL)
						fp_gv_switch = [self getFilePointer:[argv objectAtIndex:currentIndex] option:"r"];
					--argc;
					currentIndex++;
					break;
				default:
					NSLog(@"flite_hts_engine: Invalid option '-%c'.\n", secondCharacter);
			}
		} 
	}
	/* number of models,trees check */
	if (fp_ms_lf0 == NULL || fp_ms_mcp == NULL || fp_ms_dur == NULL ||
		fp_ts_lf0 == NULL || fp_ts_mcp == NULL || fp_ts_dur == NULL ||
		num_ws_lf0 == 0 || num_ws_mcp == 0) {
		NSLog(@"flite_hts_engine: specify models(trees) for each parameter.\n");
	}
	
	
	/* initialize */
	//alpha = 0.55;
	Flite_HTS_Engine_initialize(&engine, sampling_rate, fperiod, alpha, stage,
								beta, audio_buff_size, uv_threshold,
								use_log_gain, gv_weight_mcp, gv_weight_lf0);
	
	/* load */
	Flite_HTS_Engine_load(&engine, fp_ms_dur, fp_ts_dur, fp_ms_mcp, fp_ts_mcp,
						  fp_ws_mcp, num_ws_mcp, fp_ms_lf0, fp_ts_lf0, fp_ws_lf0,
						  num_ws_lf0, fp_ms_gvm, fp_ts_gvm, fp_ms_gvl, fp_ts_gvl,
						  fp_gv_switch);
	
	fclose(fp_ms_mcp);
	fclose(fp_ms_lf0);
	fclose(fp_ms_dur);
	fclose(fp_ts_mcp);
	fclose(fp_ts_lf0);
	fclose(fp_ts_dur);
	for (i = 0; i < num_ws_mcp; i++)
		fclose(fp_ws_mcp[i]);
	for (i = 0; i < num_ws_lf0; i++)
		fclose(fp_ws_lf0[i]);
	free(fp_ws_mcp);
	free(fp_ws_lf0);
	if (fp_ms_gvm != NULL)
		fclose(fp_ms_gvm);
	if (fp_ts_gvm != NULL)
		fclose(fp_ts_gvm);
	if (fp_ms_gvl != NULL)
		fclose(fp_ms_gvl);
	if (fp_ts_gvl != NULL)
		fclose(fp_ts_gvl);
	if (fp_gv_switch != NULL)
		fclose(fp_gv_switch);	
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
	cleanString = [NSMutableString stringWithString:[cleanString capitalizedString]];
	//sound = flite_text_to_wave([cleanString UTF8String], voice);
	
	/*
	 // copy sound into soundObj -- doesn't yet work -- can anyone help fix this?
	 soundObj = [NSData dataWithBytes:sound length:sizeof(sound)]; // find out wy this doesn't work
	 NSError *sAudioPlayerErr;
	 AVAudioPlayer *sAudioPlayer = [[AVAudioPlayer alloc] initWithData:soundObj error:&sAudioPlayerErr];
	 NSLog(@"%@", [sAudioPlayerErr localizedDescription]);
	 [sAudioPlayer setDelegate:self];
	 [sAudioPlayer prepareToPlay];
	 [sAudioPlayer play];
	 NSLog(@"%@", [sAudioPlayerErr localizedDescription]);
	 */
	
	NSArray *filePaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *recordingDirectory = [filePaths objectAtIndex: 0];
	// Pick a file name
	NSString *tempFilePath = [NSString stringWithFormat: @"%@/%s%i", recordingDirectory, "temp.wav", test];	// save wave to disk
	char *path;	
	path = (char*)[tempFilePath UTF8String];
	//cst_wave_save_riff(sound, path);
	
	
	FILE *wavfp = NULL;
	//wavfp = [self getFilePointer:@"temp.wav" option:"wb"];
	wavfp = Getfp(path, "wb");
	/* synthesis */
	/* free */
	Flite_HTS_Engine_clear(&engine);
	[self setUpEngine:[self getCommandParameters]];
	/* synthesis */
	
	Flite_HTS_Engine_synthesis(&engine, (char*)[cleanString UTF8String] , wavfp, pitch);
	
	fclose(wavfp);
	// Play the sound back.
	NSError *err;
	[audioPlayer stop];
	audioPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:tempFilePath] error:&err];
	[audioPlayer setDelegate:self];
	[audioPlayer setVolume:volumeLevel];
	[audioPlayer prepareToPlay];
	[audioPlayer play];
	// Remove file
	[[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
	
}

-(void)setVolume:(float)level
{
	volumeLevel = level;
}

-(void)setPitch:(float)pitch variance:(float)variance speed:(float)speed
{
	//feat_set_float(voice->features,"int_f0_target_mean", pitch);
	//feat_set_float(voice->features,"int_f0_target_stddev",variance);
	//feat_set_float(voice->features,"duration_stretch",speed); 
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
