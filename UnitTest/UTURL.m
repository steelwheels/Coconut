/**
 * @file	UTURL.m
 * @brief	Unit test function for NSURL extension
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "UnitTest.h"

static void checkURL(NSURL * url, NSError * error) ;
static const char * flagToString(BOOL flag) ;

void
testURL(void)
{
	NSError * error = nil ;
	NSURL * url0 = [NSURL allocateURLForFile: @"UnitTest.log.OK" error: &error] ;
	checkURL(url0, error) ;
}

static void
checkURL(NSURL * url, NSError * error)
{
	if(url == nil){
		[error printToFile: stdout] ;
		return ;
	}

	printf("isFileURL : \"%s\"\n", flagToString([url isFileURL])) ;
}

static const char *
flagToString(BOOL flag)
{
	return flag ? "Yes" : "No" ;
}