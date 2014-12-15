/**
 * @file	CNTextLine.m
 * @brief	Define CNTextLine class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNTextLine.h"
#import "CNTextElement.h"

@implementation CNTextLine

- (instancetype) initWithString: (NSString *) str
{
	if((self = [super initWithElementKind: CNTextLineElement]) != nil){
		self.string = str ;
	}
	return self ;
}

- (void) printToFile: (FILE *) outfp withIndent: (NSUInteger) indent
{
	[CNTextElement printIndent: indent toFile: outfp] ;
	fputs([self.string UTF8String], outfp) ;
	fputc('\n', outfp) ;
}

@end
