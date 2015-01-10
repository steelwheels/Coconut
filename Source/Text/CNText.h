/**
 * @file	CNText.h
 * @brief	Define CNText class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>

@protocol CNTextOperatiing <NSObject>
- (NSUInteger) lineCount ;
- (void) printToFile: (FILE *) outfp withIndent: (NSUInteger) indent ;
@end

@interface CNText : NSObject <CNTextOperatiing>

- (void) printToFile: (FILE *) outfp ;

+ (void) printIndent: (NSUInteger) indent toFile: (FILE *) outfp ;
+ (void) printString: (NSString *) str withIndent: (NSUInteger) indent toFile: (FILE *) outfp ;

@end

