/**
 * @file	CNCountTimer.h
 * @brief	Define CNCountTimer class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>
#import "CNForwarders.h"

@protocol CNTimerWakeupDelegate
- (void) wakeupByTimerCurrentValue: (double) time withCount: (unsigned int) count ;
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
	unsigned int		currentCount ;
}

- (instancetype) init ;
- (void) dealloc ;

- (void) addDelegate: (id <CNTimerWakeupDelegate>) delegate ;
- (bool) startFromTime: (double) start toTime: (double) stop withInterval: (double) interval ;

@end
