/**
 * @file	CNError.m
 * @brief	Extend NSError class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNError.h"

static NSString * s_errorDomain = @"github.com.steelwheels.Coconut" ;

@implementation NSError (CNErrorExtension)

+ (NSError *) parseErrorWithMessage: (NSString *) message
{
	NSDictionary * errorinfo = @{NSLocalizedDescriptionKey: message};
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
