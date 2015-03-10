/**
 * @file	CNCountTimer.h
 * @brief	Define CNCountTimer class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>
#import "CNForwarders.h"

@protocol CNTimerWakeupDelegate
- (void) triggerAtTime: (double) time isLast: (bool) islast ;
@end

@interface CNCountTimer : NSObject
{
	id <CNTimerWakeupDelegate>	timerDelegate ;

	NSTimer	*			timerBody ;
	
	double				startTime ;
	double				intervalTime ;
	double				stopTime ;
	double				currentTime ;
}

- (instancetype) initWithDelegate: (id <CNTimerWakeupDelegate>) delegate ;
- (void) dealloc ;
- (bool) startFromTime: (double) start toTime: (double) stop withInterval: (double) interval ;

@end
