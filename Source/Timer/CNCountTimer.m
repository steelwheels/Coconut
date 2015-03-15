/**
 * @file	CNCountTimer.m
 * @brief	Define CNCountTimer class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNCountTimer.h"

@interface CNCountTimer (CNPrivate)
- (void) triggerByTimer ;
@end

@implementation CNCountTimer

- (instancetype) init
{
	if((self = [super init]) != nil){
		timerDelegates		= [[NSMutableArray alloc] init] ;
		timerBody		= nil ;
		
		startTime		= 0.0 ;
		intervalTime		= 0.0 ;
		stopTime		= 0.0 ;
		currentTime		= startTime ;
	}
	return self ;
}

- (void) dealloc
{
	if(timerBody){
		[timerBody invalidate] ;
	}
}

- (void) addDelegate: (id <CNTimerWakeupDelegate>) delegate
{
	[timerDelegates addObject: delegate] ;
}

- (bool) startFromTime: (double) start toTime: (double) stop withInterval: (double) interval
{
	if(interval == 0.0){
		return false ;
	} else if(interval > 0.0){
		if(!(start <= stop)){
			return false ;
		}
	} else { // interval < 0.0
		if(!(start >= stop)){
			return false ;
		}
	}
	
	startTime	= currentTime = start ;
	stopTime	= stop ;
	intervalTime	= interval ;
	double absinterval = interval >= 0.0 ? interval : -interval ;
	timerBody = [NSTimer timerWithTimeInterval: absinterval
					    target: self
					  selector: @selector(triggerByTimer)
					  userInfo: nil
					   repeats: YES] ;
	[[NSRunLoop currentRunLoop] addTimer: timerBody forMode:NSRunLoopCommonModes];
	return true ;
}

@end

static bool
isFinished(double current, double stop, double interval)
{
	bool	isfinished ;
	if(interval > 0.0){
		if(current > stop){
			isfinished = true ;
		} else {
			isfinished = false ;
		}
	} else { // interval < 0.0
		if(current < stop){
			isfinished = true ;
		} else {
			isfinished = false ;
		}
	}
	return isfinished ;
}

@implementation CNCountTimer (CNPrivate)

- (void) triggerByTimer
{
	if(isFinished(currentTime, stopTime, intervalTime)){
		for(id <CNTimerWakeupDelegate> delegate in timerDelegates){
			[delegate wakeupByTimerDone] ;
		}
	} else {
		for(id <CNTimerWakeupDelegate> delegate in timerDelegates){
			[delegate wakeupByTimerInterval: currentTime] ;
		}
		currentTime += intervalTime ;
	}
	
}

@end
