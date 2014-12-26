/**
 * @file	CNInputFile.h
 * @brief	Define CNInputFile class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNInputStream.h"

@interface CNInputFile : CNInputStream <CNInputStreaming>
{
	FILE *	inputFp ;
}

- (instancetype) init ;
- (void) dealloc ;

@end
