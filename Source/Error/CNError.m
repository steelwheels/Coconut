/**
 * @file	CNError.m
 * @brief	Extend NSError class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNError.h"

static NSString * s_errorDomain = @"github.com.steelwheels.Coconut" ;
static NSString * s_errorLocationKey = @"errorLocation" ;

@implementation NSError (CNErrorExtension)

+ (NSError *) parseErrorWithMessage: (NSString *) message
{
	NSDictionary * errorinfo = @{NSLocalizedDescriptionKey: message};
	return [[NSError alloc] initWithDomain: s_errorDomain
					  code: CNParserError
				      userInfo: errorinfo] ;
}

+ (NSError *) parseErrorWithMessage: (NSString *) message withLocation: (CNErrorLocation *) location
{
	NSDictionary * errorinfo = @{NSLocalizedDescriptionKey: message,
				     s_errorLocationKey: location} ;
	return [[NSError alloc] initWithDomain: s_errorDomain
					  code: CNParserError
				      userInfo: errorinfo] ;
}

+ (NSError *) fileErrorWithMessage: (NSString *) message
{
	NSDictionary * errorinfo = @{NSLocalizedDescriptionKey: message};
	return [[NSError alloc] initWithDomain: s_errorDomain
					  code: CNFileError
				      userInfo: errorinfo] ;
}

+ (NSError *) memoryErrorWithMessage: (NSString *) message atFunction: (const char *) funcname
{
	if(funcname){
		NSString * filepath = [[NSString alloc] initWithFormat: @" at function \"%s\"", funcname] ;
		message = [message stringByAppendingString: filepath] ;
	}
	NSDictionary * errorinfo = @{NSLocalizedDescriptionKey: message};
	return [[NSError alloc] initWithDomain: s_errorDomain
					  code: CNMemoryError
				      userInfo: errorinfo] ;
}

+ (NSError *) memoryErrorWithKind: (CNMemoryErrorKind) kind atFunction: (const char *) funcname
{
	NSString * message = nil ;
	switch(kind){
		case CNMemoryAllocationError: {
			message = @"Memory allocation error" ;
		} break ;
		default: {
			message = @"Unkown memory error" ;
		} break ;
	}
	return [NSError memoryErrorWithMessage: message atFunction: funcname] ;
}

- (void) printToFile: (FILE *) outfp
{
	fputs("[Error] ", outfp) ;
	NSDictionary * userinfo = [self userInfo] ;
	NSString * desc = [userinfo valueForKey: NSLocalizedDescriptionKey] ;
	if(desc != nil){
		fprintf(outfp, "%s", [desc UTF8String]) ;
	}
	fputc('\n', outfp) ;
}

@end
