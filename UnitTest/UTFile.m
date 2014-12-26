/**
 * @file	UTFile.m
 * @brief	Unit test function for CNFile class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "UnitTest.h"

static void
printFile(CNInputStream * stream) ;

void
testFile(void)
{
	/* Allocate URL */
	NSError * error = nil ;
	NSURL * url = [NSURL allocateURLForFile: @"input.txt" error: &error] ;
	if(url == nil){
		[error printToFile: stdout] ;
		return ;
	}
	NSString * urlstr = [url absoluteString] ;
	printf("input file : %s\n", [urlstr UTF8String]) ;
	
	/* Open input file */
	CNInputFile * infile = [[CNInputFile alloc] init] ;
	error = [infile openByURL: url] ;
	if(error != nil){
		[error printToFile: stdout] ;
		return ;
	}
	/* Print the content */
	printFile(infile) ;
}

static void
printFile(CNInputStream * stream)
{
#	define BUFSIZE 16
	char	buf[BUFSIZE] ;
	
	NSUInteger readsize ;
	while((readsize = [stream readInto: buf withMaxSize: BUFSIZE]) > 0){
		NSUInteger i ;
		for(i=0 ; i<readsize ; i++){
			fputc(buf[i], stdout) ;
		}
	}
}