/**
 * @file	CNCountTimer.h
 * @brief	Define CNCountTimer class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>
#import "CNForwarders.h"

@protocol CNTimerWakeupDelegate
- (void) wakeupByTimerInterval: (double) time ;
- (void) wakeupByTimerDone ;
@end

@interface CNCountTimer : NSObject
{
	/* Element is id <CNTimerWakeupDelegate> */
	NSMutableArray *	timerDelegates ;

	NSTimer	*		timerBody ;
	
	double			startTime ;
	double			intervalTime ;
	double			stopTime ;
	double			currentTime ;
}

- (instancetype) init ;
- (void) dealloc ;

- (void) addDelegate: (id <CNTimerWakeupDelegate>) delegate ;
- (bool) startFromTime: (double) start toTime: (double) stop withInterval: (double) interval ;

@end
