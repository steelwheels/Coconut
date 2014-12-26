/**
 * @file	CNInputStream.m
 * @brief	Define CNInputStream class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNInputStream.h"

@implementation CNInputStream

- (NSError *) openByURL: (NSURL *) url
{
	(void) url ;
	assert(false) ;
	return nil ;
}

- (NSUInteger) readInto: (char *) buf withMaxSize: (NSUInteger) maxsize
{
	(void) buf ; (void) maxsize ;
	assert(false) ;
	return 0 ;
}

@end
