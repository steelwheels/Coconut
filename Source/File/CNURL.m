/**
 * @file	CNURL.m
 * @brief	Extend NSURL class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNURL.h"
#import "CNError.h"

@implementation NSURL (CNURLExtension)

+ (NSURL *) allocateURLForFile: (NSString *) fname error: (NSError **) error
{
	/* if file name is nil or empty, return error */
	if(fname == nil || [fname length] == 0){
		if(error){
			*error = [NSError parseErrorWithMessage: @"No input file name"] ;
		}
		return nil ;
	}
	
	/* check scheme */
	if([NSURL schemeOfString: fname] != CNURINoScheme){
		return [[NSURL alloc] initWithString: fname] ;
	}
	
	/* Standardizing path string */
	NSString * stdpath = [fname stringByStandardizingPath] ;
	
	/* If the path not is not absolute, add current path */
	NSString * resstr ;
	if(![stdpath hasPrefix: @"/"]){
		NSFileManager * filemgr = [NSFileManager defaultManager] ;
		NSString * curdir = [filemgr currentDirectoryPath] ;
		NSString * fullpath = [NSString stringWithFormat: @"file://%@/%@", curdir, stdpath] ;
		resstr = [fullpath stringByStandardizingPath] ;
	} else {
		resstr = [NSString stringWithFormat: @"file://%@", stdpath] ;
	}
	return [[NSURL alloc] initWithString: resstr] ;
}

+ (CNURIScheme) schemeOfString: (NSString *) src
{
	CNURIScheme result ;
	if(strncmp([src UTF8String], "https:", 6) == 0){
		result = CNURIHttpsScheme ;
	} else if(strncmp([src UTF8String], "http:", 5) == 0){
		result = CNURIHttpScheme ;
	} else if(strncmp([src UTF8String], "file:", 5) == 0){
		result = CNURIFileScheme ;
	} else {
		result = CNURINoScheme ;
	}
	return result ;
}

@end


