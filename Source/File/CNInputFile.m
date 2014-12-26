/**
 * @file	CNInputFile.m
 * @brief	Define CNInputFile class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNInputFile.h"
#import "CNError.h"

static const char *
normalizeFileName(const char * name) ;

@implementation CNInputFile

- (instancetype) init
{
	if((self = [super init]) != nil){
		inputFp = NULL ;
	}
	return self ;
}

- (NSError *) openByURL: (NSURL *) url
{
	NSString *	errormessage  ;
	NSString *	filestr = [url relativeString] ;
	const char *	filename = [filestr UTF8String] ;
	
	inputFp = NULL ;
	if([url isFileURL]){
		const char * normname = normalizeFileName(filename) ;
		if((inputFp = fopen(normname, "r")) != NULL){
			errormessage = nil ;
		} else {
			errormessage = [[NSString alloc] initWithFormat: @"Can not read file: \"%s\"", filename] ;
		}
	} else {
		errormessage = [[NSString alloc] initWithFormat: @"Invalid file URL: \"%s\"", filename] ;
	}
	
	if(errormessage){
		return [NSError fileErrorWithMessage: errormessage] ;
	} else {
		return nil ; /* No error */
	}
}

- (void) dealloc
{
	if(inputFp){
		fclose(inputFp) ;
	}
}

- (NSUInteger) readInto: (char *) buf withMaxSize: (NSUInteger) maxsize
{
	NSUInteger cursize ;
	for(cursize=0 ; cursize<maxsize ; cursize++){
		char c = fgetc(inputFp) ;
		if(c != EOF){
			*buf = c ;
			buf++ ;
		} else {
			break ;
		}
	}
	return cursize ;
}

@end

static const char *
normalizeFileName(const char * name)
{
	if(strncmp(name, "file:", 5) == 0){
		name += 5 ;
	}
	return name ;
}
