/**
 * @file	CNError.h
 * @brief	Extend NSError class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>
#import "CNForwarders.h"

typedef enum {
	CNParserError,
	CNFileError,
	CNMemoryError
} CNErrorCode ;

typedef enum {
	CNMemoryAllocationError
} CNMemoryErrorKind ;

@interface NSError (CNErrorExtension)

+ (NSError *) parseErrorWithMessage: (NSString *) message ;
+ (NSError *) parseErrorWithMessage: (NSString *) message withLocation: (CNErrorLocation *) location ;
+ (NSError *) fileErrorWithMessage: (NSString *) message ;
+ (NSError *) memoryErrorWithMessage: (NSString *) message atFunction: (const char *) funcname ;
+ (NSError *) memoryErrorWithKind: (CNMemoryErrorKind) kind atFunction: (const char *) funcname ;

- (void) printToFile: (FILE *) outfp ;

@end
