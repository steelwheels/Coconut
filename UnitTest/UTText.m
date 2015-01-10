/**
 * @file	UTText.m
 * @brief	Unit test function for CNText class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "UnitTest.h"

static void
printLineCount(const char * varname, CNText * text) ;

void
testText(void)
{
	CNTextSection * sec0 = [[CNTextSection alloc] init] ;
	sec0.sectionTitle = @"Section 0" ;
	[sec0 appendChildText: [[CNTextLine alloc] initWithString: @"line0"]] ;
	[sec0 appendChildText: [[CNTextLine alloc] initWithString: @"line1"]] ;
	
	CNTextCompound * comp0 = [[CNTextCompound alloc] init] ;
	comp0.headerString = @"comp0.header" ;
	comp0.middleString = @"comp0.middle" ;
	comp0.tailString   = @"comp0.tail" ;
	[comp0 appendChildText: [[CNTextLine alloc] initWithString: @"line0"]] ;
	[comp0 appendChildText: [[CNTextLine alloc] initWithString: @"line1"]] ;
	[comp0 appendChildText: [[CNTextLine alloc] initWithString: @"line2"]] ;
	
	CNTextSection * sec1 = [[CNTextSection alloc] init] ;
	[sec1 appendChildText: [[CNTextLine alloc] initWithString: @"line10"]] ;
	[sec1 appendChildText: sec0] ;
	[sec1 appendChildText: [[CNTextLine alloc] initWithString: @"line11"]] ;
	[sec1 appendChildText: comp0] ;
	
	[sec1 printToFile: stdout] ;
	
	printLineCount("sec0", sec0) ;
	printLineCount("comp0", comp0) ;
	printLineCount("sec1", sec1) ;
}


static void
printLineCount(const char * varname, CNText * text)
{
	NSUInteger count = [text lineCount] ;
	printf("line count of %s -> %tu\n", varname, count) ;
}