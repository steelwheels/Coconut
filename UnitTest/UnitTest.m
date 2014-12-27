/**
 * @file	UnitTest.m
 * @brief	Header file for the unit test of KiwiData library
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "UnitTest.h"

static void printTitle(const char * message) ;
static void printLine(void) ;

int main(int argc, const char * argv[]) {
	((void) argc) ; ((void) argv) ;
	@autoreleasepool {
	    // insert code here...
	    printf("UnitTest of KiwiData framework\n");
		
		printTitle("CNError") ;			testError() ;
		printTitle("CNList") ;			testList() ;
		printTitle("CNValue") ;			testValue() ;
		printTitle("CNText") ;			testText() ;
		printTitle("CNRegularExpression");	testRegularExpression() ;
		printTitle("CNURL") ;			testURL() ;
		printTitle("CNInputFile") ;		testFile() ;
	}
    return 0;
}

static void
printTitle(const char * message)
{
	printLine() ;
	printf("* %s\n", message) ;
	printLine() ;
}

static void
printLine(void)
{
	unsigned int i ;
	for(i=0 ; i<80 ; i++){
		fputc('*', stdout) ;
	}
	fputc('\n', stdout) ;
}