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
		timerBody	= nil ;
		timerDelegate	= nil ;
		downCount	= 0 ;
		intervalTime	= 0.0 ;
	}
	return self ;
}

- (void) dealloc
{
	if(timerBody){
		[timerBody invalidate] ;
	}
}

- (void) repeatWithCount: (unsigned int) count withInterval: (double) interval withDelegate: (id <CNCountTimerDelegate>) delegate
{
	if((downCount = count) > 0){
		timerDelegate = delegate ;
		intervalTime = interval ;
		timerBody = [NSTimer timerWithTimeInterval: intervalTime
						    target: self
						  selector: @selector(triggerByTimer)
						  userInfo: nil
						   repeats: YES] ;
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop] ;
		[runLoop addTimer: timerBody forMode:NSRunLoopCommonModes] ;
	} else {
		[delegate repeatDone] ;
	}
}

@end

@implementation CNCountTimer (CNPrivate)

- (void) triggerByTimer
{
	if(downCount > 0){
		[timerDelegate repeatForCount: downCount-1] ;
		downCount-- ;
	} else {
		[timerDelegate repeatDone] ;
		[timerBody invalidate] ;
		timerBody = nil ;
	}
}

@end
