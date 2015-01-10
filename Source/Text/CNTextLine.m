/**
 * @file	CNTextLine.m
 * @brief	Define CNTextLine class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNTextLine.h"
#import "CNTextVisitor.h"

@implementation CNTextLine

- (instancetype) initWithString: (NSString *) str
{
	if((self = [super init]) != nil){
		self.string = str ;
	}
	return self ;
}

- (NSUInteger) lineCount
{
	return 1 ;
}

- (id) acceptVisitor: (CNTextVisitor *) visitor withParameter: (id) param
{
	return [visitor acceptTextLine: self withParameter: param] ;
}

- (void) printToFile: (FILE *) outfp withIndent: (NSUInteger) indent
{
	[CNText printString: self.string withIndent: indent toFile: outfp] ;
}

@end
