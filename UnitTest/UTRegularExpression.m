/**
 * @file	UTRegularExpression.m
 * @brief	Unit test function for CNRegularExpression class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "UnitTest.h"

static void
matchTest(const char * pat) ;
static void
matchOneTest(const char * pat, const char * text) ;

void
testRegularExpression(void)
{
	matchTest("^a") ;
}

static void
matchTest(const char * pat)
{
	matchOneTest(pat, "") ;
	matchOneTest(pat, "a") ;
	matchOneTest(pat, "ba") ;
	matchOneTest(pat, "aa") ;
}

static void
matchOneTest(const char * pat, const char * text)
{
	NSError * error ;
	NSString * patobj = [[NSString alloc] initWithUTF8String: pat] ;
	CNRegularExpression * regexp ;
	regexp = [[CNRegularExpression alloc] initWithString: patobj error: &error] ;
	if(regexp == nil){
		[error printToFile: stdout] ;
		return ;
	}
	printf("match with \"%s\" -> ", text) ;
	if([regexp matchWithCString: text]){
		puts("matched") ;
	} else {
		puts("Not matched") ;
	}
}