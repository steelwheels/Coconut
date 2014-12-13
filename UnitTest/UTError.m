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
	NSError * error = [NSError parseErrorWithMessage: @"Test message"] ;
	[error printToFile: stdout] ;
}