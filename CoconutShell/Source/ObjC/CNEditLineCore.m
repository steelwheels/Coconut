/**
 * @file	CNEditLineCore.m
 * @brief	Define CNEditLineCore class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

#import "CNEditLineCore.h"
#import <histedit.h>

static char * promptFunc(EditLine * editline)
{
	return "> " ;
}

@implementation CNEditLineCore

- (instancetype) init
{
	if((self = [super init]) != nil){
		mEditLine = NULL ;
	}
	return self ;
}

- (void) dealloc
{
	[self finalize] ;
}

- (void) setup: (nonnull NSString *) name  withInput: (nonnull NSFileHandle *) inhdl withOutput: (nonnull NSFileHandle *) outhdl withError: (nonnull NSFileHandle *) errhdl
{
	const char * pname = name.UTF8String ;
	FILE * infp  = fdopen(inhdl.fileDescriptor, "r") ;
	FILE * outfp = fdopen(outhdl.fileDescriptor, "w") ;
	FILE * errfp = fdopen(errhdl.fileDescriptor, "w") ;

	mEditLine = el_init(pname, infp, outfp, errfp) ;

	el_set(mEditLine, EL_PROMPT, &promptFunc) ;
}

- (void) finalize
{
	if(mEditLine != NULL){
		el_end(mEditLine) ;
		mEditLine = NULL ;
	}
}

- (void) reset
{
	el_reset(mEditLine) ;
}

- (void) setBufferedMode: (BOOL) mode
{
	int unbufmode = mode ? 0 : 1 ;
	el_set(mEditLine, EL_UNBUFFERED, unbufmode) ;
}

- (BOOL) bufferedMode
{
	int unbufmode ;
	int result = el_get(mEditLine, EL_UNBUFFERED, &unbufmode) ;
	if(result == 0){
		return (unbufmode != 0) ;
	} else {
		NSLog(@"Failed to get buffered mode") ;
		return false ;
	}
}

- (nullable NSString *) gets
{
	int count = 0 ;
	const char * str = el_gets(mEditLine, &count) ;
	if(str){
		return [[NSString alloc] initWithUTF8String: str] ;
	} else {
		return nil ;
	}
}

- (char) getc
{
	char c ;
	if(el_getc(mEditLine, &c) > 0){
		return c ;
	} else {
		return EOF ;
	}
}

@end
