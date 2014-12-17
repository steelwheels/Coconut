/**
 * @file	CNText.m
 * @brief	Define CNText class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNText.h"

@implementation CNText

@synthesize elementKind ;

- (instancetype) initWithElementKind: (CNTextKind) kind
{
	if((self = [super init]) != nil){
		self.elementKind = kind ;
	}
	return self ;
}

- (void) printToFile: (FILE *) outfp withIndent: (NSUInteger) indent
{
	((void) outfp) ; ((void) indent) ;
	assert(false) ;
}

- (void) printToFile: (FILE *) outfp
{
	[self printToFile: outfp withIndent: 0] ;
}

+ (void) printIndent: (NSUInteger) indent toFile: (FILE *) outfp
{
	NSUInteger	i ;
	for(i=0 ; i<indent ; i++){
		fputs("  ", outfp) ;
	}
}

+ (void) printString: (NSString *) str withIndent: (NSUInteger) indent toFile: (FILE *) outfp
{
	[CNText printIndent: indent toFile: outfp] ;
	fputs([str UTF8String], outfp) ;
	fputc('\n', outfp) ;
}

@end
