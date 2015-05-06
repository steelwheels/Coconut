/**
 * @file	UTTimer.m
 * @brief	Unit test function for CNCountTimer class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

#import "UnitTest.h"

enum UTTimerState {
	UT1stState,
	UT2ndState,
	UTFinalState
} ;

static const char *
state2string(enum UTTimerState state) ;

@interface UTTimerTester : NSObject <CNCountTimerDelegate>

@property (assign, nonatomic) enum UTTimerState		state ;

- (instancetype) init ;

@end

@implementation UTTimerTester

- (instancetype) init
{
	if((self = [super init]) != nil){
		self.state = UT1stState ;
	}
	return self ;
}

- (void) repeatForCount: (unsigned int) count
{
	printf("[%s] repeatForCount: %u\n", state2string(self.state), count) ;
}

- (void) repeatDone
{
	printf("[%s] repeatDone\n", state2string(self.state)) ;
	switch(self.state){
		case UT1stState: {
			self.state = UT2ndState ;
		} break ;
		case UT2ndState: {
			self.state = UTFinalState ;
		} break ;
		case UTFinalState: {
			/* Nothing have to do */
		} break ;
	}
}

@end

void testTimer(void)
{
	CNCountTimer *	timer = [[CNCountTimer alloc] init] ;
	UTTimerTester *	tester = [[UTTimerTester alloc] init] ;
	NSRunLoop *	runloop = [NSRunLoop currentRunLoop];

	/* Run timer */
	[timer repeatWithCount: 5 withInterval: 0.5 withDelegate: tester] ;
	while(tester.state == UT1stState){
		[runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	}
	
	/* Run timer again */
	[timer repeatWithCount: 3 withInterval: 0.6 withDelegate: tester] ;
	while(tester.state == UT2ndState){
		[runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	}
}

static const char *
state2string(enum UTTimerState state)
{
	const char * result = "?" ;
	switch(state){
		case UT1stState: {
			result = "1st-state" ;
		} break ;
		case UT2ndState: {
			result = "2nd-state" ;
		} break ;
		case UTFinalState: {
			result = "final-state" ;
		} break ;
	}
	return result ;
}
