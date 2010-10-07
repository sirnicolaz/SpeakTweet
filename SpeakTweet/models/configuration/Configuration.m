#import "Configuration.h"
#import "Colors.h"
#import "Notification.h"
#import "ConfigurationKeys.h"

@implementation Configuration

@synthesize useSafari, autoScroll, showMoreTweetMode, shakeToFullscreen; //darkColorTheme
@synthesize lefthand;
static id _instance = nil;

+ (id) instance {
    @synchronized (self) {
        if (!_instance) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

- (id) init {
	if (self = [super init]) {
		[self reload];
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void)reload {
	refreshIntervalSeconds = [[NSUserDefaults standardUserDefaults] integerForKey:PREFERENCE_REFRESH_INTERVAL];
	useSafari = [[NSUserDefaults standardUserDefaults] boolForKey:PREFERENCE_USE_SAFARI];
	//darkColorTheme = [[NSUserDefaults standardUserDefaults] boolForKey:PREFERENCE_DARK_COLOR_THEME];
	autoScroll = [[NSUserDefaults standardUserDefaults] boolForKey:PREFERENCE_AUTO_SCROLL];
	showMoreTweetMode = [[NSUserDefaults standardUserDefaults] boolForKey:PREFERENCE_SHOW_MORE_TWEETS_MODE];
	fetchCount = [[NSUserDefaults standardUserDefaults] integerForKey:PREFERENCE_FETCH_COUNT];
	shakeToFullscreen = [[NSUserDefaults standardUserDefaults] boolForKey:PREFERENCE_SHAKE_TO_FULLSCREEN];
	lefthand = [[NSUserDefaults standardUserDefaults] boolForKey:PREFERENCE_LEFTHAND];
	//ST: set the voice
	voice = [[NSUserDefaults standardUserDefaults] integerForKey:ST_PREFERENCE_VOICE];
	
}

static int seconds_from_index(int index)
{
	if (index == 0) return 0;
	if (index > 6) return 0;
	
	const int m[] = {1*60,2*60,2*60+30,3*60,5*60,10*60};
	return m[index-1];
}

static int count_from_index(int index)
{
	if (index > 3) return 0;
	
	const int m[] = {20,50,100,200};
	NSLog(@"DIOCANEE %d", m[index]);
	return m[index];
}

//ST: pick up che voice from the selected index
static NSString* voice_from_index(int index)
{
	if(index == 0) return @"woman";
	return @"man";
}

//ST: pick up the volume level from the selected index
static float volume_from_index(int index)
{
	/*switch (index) {
	 case 0:
	 return 0.1;
	 case 1:
	 return 0.5;
	 case 2:
	 return 1.0;
	 default:
	 return 0.5;
	 }*/
	
	return 0.5;
}

- (int)refreshIntervalSeconds {
	return seconds_from_index(refreshIntervalSeconds);
}

- (int)fetchCount {
	return count_from_index(fetchCount);
}

//ST: get the voice string identifier
- (NSString *)voice{
	return voice_from_index(voice);
}

//ST: get voice volume
- (float)volume{
	return volume_from_index(volume);
}

@end