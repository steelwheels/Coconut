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
		reserveInvalidate	= NO ;
		timerDelegate		= nil ;
		downCount		= 0 ;
		intervalTime		= 0.0 ;
	}
	return self ;
}

- (void) repeatWithCount: (unsigned int) count withInterval: (double) interval withDelegate: (id <CNCountTimerDelegate>) delegate
{
	if((downCount = count) > 0){
		timerDelegate = delegate ;
		intervalTime = interval ;
		reserveInvalidate = NO ;
		NSTimer * timer = [NSTimer timerWithTimeInterval: intervalTime
							  target: self
							selector: @selector(triggerByTimer:)
							userInfo: nil
							 repeats: YES] ;
		//printf("%s start timer on runloop\n", __func__) ;
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop] ;
		[runLoop addTimer: timer forMode:NSRunLoopCommonModes] ;
	} else {
		[delegate repeatDone] ;
	}
}

- (void) invalidate
{
	reserveInvalidate = YES ;
}

@end

@implementation CNCountTimer (CNPrivate)

- (void) triggerByTimer: (NSTimer *) timer
{
	//printf("%s count %u -> ", __func__, downCount) ;
	if(downCount > 0 && !reserveInvalidate){
		[timerDelegate repeatForCount: downCount-1] ;
		downCount-- ;
		//puts("continue") ;
	} else {
		[timerDelegate repeatDone] ;
		[timer invalidate] ;
		reserveInvalidate = NO ;
		//puts("invalidate") ;
	}
}

@end
