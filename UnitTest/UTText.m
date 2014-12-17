/**
 * @file	UTText.m
 * @brief	Unit test function for CNText class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "UnitTest.h"

void
testText(void)
{
	CNTextSection * sec0 = [[CNTextSection alloc] init] ;
	sec0.sectionTitle = @"Section 0" ;
	[sec0 appendChildText: [[CNTextLine alloc] initWithString: @"line0"]] ;
	[sec0 appendChildText: [[CNTextLine alloc] initWithString: @"line1"]] ;
	CNTextSection * sec1 = [[CNTextSection alloc] init] ;

	[sec1 appendChildText: [[CNTextLine alloc] initWithString: @"line10"]] ;
	[sec1 appendChildText: sec0] ;
	[sec1 appendChildText: [[CNTextLine alloc] initWithString: @"line11"]] ;
	
	[sec1 printToFile: stdout] ;
}