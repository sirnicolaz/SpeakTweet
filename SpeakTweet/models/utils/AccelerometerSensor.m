#import "AccelerometerSensor.h"
#import "Configuration.h"

static AccelerometerSensor *_sharedInstance;

@interface AccelerometerSensor(Private)
- (void)accIntervalTimerExpired;
- (void)accIntervalTimerStart;
@end


@implementation AccelerometerSensor

@synthesize delegate;

+ (AccelerometerSensor*)sharedInstance {
	if (_sharedInstance == nil) {
		_sharedInstance = [[AccelerometerSensor alloc] init];
	}
	return _sharedInstance;
}

- (id)init {
	if (self = [super init]) {
		[self updateByConfiguration];
	}
	return self;
}

- (void)dealloc {
	[self accIntervalTimerExpired];
	[delegate release];
	[super dealloc];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	const UIAccelerationValue gthreshold = 1.7;
	const UIAccelerationValue filterFactor = 0.1;
	const CFTimeInterval interval = 0.5;
		
	accAvg[0] = acceleration.x * filterFactor + accAvg[0] * (1.0 - filterFactor);
	accAvg[1] = acceleration.y * filterFactor + accAvg[1] * (1.0 - filterFactor);
	accAvg[2] = acceleration.z * filterFactor + accAvg[2] * (1.0 - filterFactor);
	
	UIAccelerationValue x = acceleration.x - accAvg[0];
	UIAccelerationValue y = acceleration.y - accAvg[1];
	UIAccelerationValue z = acceleration.z - accAvg[2];
	
	UIAccelerationValue g = sqrt(x*x + y*y + z*z);
	
	CFTimeInterval now = CFAbsoluteTimeGetCurrent();
	if (g > gthreshold && now > lastFired + interval) {
		[delegate accelerometerSensorDetected];
		lastFired = now;
	}
}

- (void)updateByConfiguration {
	if ([[Configuration instance] shakeToFullscreen]) {
		[UIAccelerometer sharedAccelerometer].delegate = self;
		[UIAccelerometer sharedAccelerometer].updateInterval = 0.05;
	} else {
		[UIAccelerometer sharedAccelerometer].delegate = nil;
		[UIAccelerometer sharedAccelerometer].updateInterval = 1.0;
	}
}


@end
