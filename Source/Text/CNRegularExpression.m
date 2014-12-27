/**
 * @file	CNRegularExpression.m
 * @brief	Define CNRegularExpression class
 * @par Copyright
 *   Copyright (C) 2007 Steel Wheels Project
 */

#import "CNRegularExpression.h"
#import "CNError.h"

/** Size of buffers to keep matched patterns */
#define	MATCHED_PATTERN_SIZE			128

@implementation CNRegularExpression

- (id) initWithString: (NSString *) pattern error: (NSError **) error
{
	if((self = [super init]) != nil){
		regularExpression = NULL ;
		matchedPatterns = NULL ;
		
		/* allocate memory space */
		regularExpression = (regex_t *) NSZoneMalloc(NSDefaultMallocZone(), sizeof(regex_t)) ;
		if(regularExpression == NULL){
			*error = [NSError memoryErrorWithKind: CNMemoryAllocationError atFunction: __func__] ;
			return nil ;
		}
		
		const char *	patstr = [pattern UTF8String] ;
		int				compres ;
		if((compres = regcomp(regularExpression, patstr, REG_EXTENDED)) != 0){
			/* Some error occured */
			char	message[512] ;
			regerror(compres, regularExpression, message, 511) ;
			message[511] = '\0' ;
			/* create error object */
			NSString * msgobj = [[NSString alloc] initWithUTF8String: message] ;
			*error = [NSError memoryErrorWithMessage: msgobj atFunction: __func__] ;
			return nil ;
		}
		
		matchedPatterns = (regmatch_t *) NSZoneMalloc(NSDefaultMallocZone(), sizeof(regmatch_t) * 
		  MATCHED_PATTERN_SIZE) ;
		if(matchedPatterns == NULL){
			*error = [NSError memoryErrorWithKind: CNMemoryAllocationError atFunction: __func__] ;
			return nil ;
		}
	}
	return self ;
}

- (void) dealloc
{
	if(regularExpression != NULL){
		regfree(regularExpression) ;
		NSZoneFree(NSDefaultMallocZone(), regularExpression) ;
	}
	if(matchedPatterns != NULL){
		NSZoneFree(NSDefaultMallocZone(), matchedPatterns) ;
	}
}

- (BOOL) matchWithCString: (const char *) str
{
	int result = regexec(regularExpression, str, MATCHED_PATTERN_SIZE,
	  matchedPatterns, 0) ;
	return (result == 0) ;
}

- (BOOL) matchWithString: (NSString *) str
{
	int result = regexec(regularExpression, [str UTF8String], MATCHED_PATTERN_SIZE,
	  matchedPatterns, 0) ;
	return (result == 0) ;
}

@end
