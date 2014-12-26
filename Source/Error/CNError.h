/**
 * @file	CNError.h
 * @brief	Extend NSError class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>

typedef enum {
	CNParserError,
	CNFileError
} CNErrorCode ;

@interface NSError (CNErrorExtension)

+ (NSError *) parseErrorWithMessage: (NSString *) message ;
+ (NSError *) fileErrorWithMessage: (NSString *) message ;
- (void) printToFile: (FILE *) outfp ;

@end
