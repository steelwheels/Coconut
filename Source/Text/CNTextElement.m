/**
 * @file	CNTextElement.m
 * @brief	Define CNTextElement class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNTextElement.h"

@implementation CNTextElement

@synthesize elementKind ;

- (instancetype) initWithElementKind: (CNTextElementKind) kind
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

+ (void) printIndent: (NSUInteger) indent toFile: (FILE *) outfp
{
	NSUInteger	i ;
	for(i=0 ; i<indent ; i++){
		fputs("  ", outfp) ;
	}
}

@end
