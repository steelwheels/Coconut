/**
 * @file	CNCountTimer.m
 * @brief	Define CNCountTimer class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNCountTimer.h"

@interface CNCountTimer (CNPrivate)
- (void) triggerByTimer: (NSTimer *) timer ;
@end

@implementation CNCountTimer

- (instancetype) init
{
	if((self = [super init]) != nil){
		doInvalidate		= NO ;
		timerDelegate		= nil ;
		downCount		= 0 ;
	}
	return self ;
}

- (void) repeatWithCount: (unsigned int) count withInterval: (double) interval withDelegate: (id <CNCountTimerDelegate>) delegate
{
	if((downCount = count) > 0){
		timerDelegate = delegate ;
		NSTimer * timer = [NSTimer timerWithTimeInterval: interval
							  target: self
							selector: @selector(triggerByTimer:)
							userInfo: nil
							 repeats: YES] ;
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop] ;
		[runLoop addTimer: timer forMode:NSRunLoopCommonModes] ;
	} else {
		[delegate repeatDone] ;
	}
}

- (void) invalidate
{
	if(downCount > 0){
		doInvalidate = YES ;
	}
}

@end

@implementation CNCountTimer (CNPrivate)

- (void) triggerByTimer: (NSTimer *) timer
{
	if(downCount > 0 && !doInvalidate){
		[timerDelegate repeatForCount: downCount-1] ;
		downCount-- ;
	} else {
		[timerDelegate repeatDone] ;
		[timer invalidate] ;
		doInvalidate = NO ;
	}
}

@end


