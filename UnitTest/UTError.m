/**
 * @file	UTError.m
 * @brief	Unit test function for NSError class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "UnitTest.h"

void
testError(void)
{
	NSError * error0 = [NSError parseErrorWithMessage: @"Test message"] ;
	[error0 printToFile: stdout] ;
	
	NSError * error1 = [NSError memoryErrorWithKind: CNMemoryAllocationError
					     atFunction: "__func1__"] ;
	[error1 printToFile: stdout] ;
}