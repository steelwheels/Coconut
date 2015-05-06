/**
 * @file	CNCountTimer.h
 * @brief	Define CNCountTimer class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>
#import "CNForwarders.h"

@protocol CNCountTimerDelegate
- (void) repeatForCount: (unsigned int) count ;
- (void) repeatDone ;
@end

@interface CNCountTimer : NSObject
{
	BOOL				doInvalidate ;
	id <CNCountTimerDelegate>	timerDelegate ;
	unsigned int			downCount ;
}

- (instancetype) init ;
- (void) repeatWithCount: (unsigned int) count withInterval: (double) interval withDelegate: (id <CNCountTimerDelegate>) delegate ;
- (void) invalidate ;

@end
