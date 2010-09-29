#import <UIKit/UIKit.h>

@protocol AccelerometerSensorDelegate 

- (void)accelerometerSensorDetected;

@end

@interface AccelerometerSensor : NSObject<UIAccelerometerDelegate> {
	NSObject<AccelerometerSensorDelegate> *delegate;
	UIAccelerationValue accAvg[3];
	CFTimeInterval lastFired;
}

+ (AccelerometerSensor*)sharedInstance;

- (void)updateByConfiguration;

@property (readwrite, retain) NSObject<AccelerometerSensorDelegate> *delegate;

@end
