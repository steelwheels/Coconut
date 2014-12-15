/**
 * @file	CNText.m
 * @brief	Define CNText class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNText.h"
#import "CNTextSection.h"

@implementation CNText

@synthesize rootSection ;

- (instancetype) init
{
	if((self = [super init]) != nil){
		self.rootSection = [[CNTextSection alloc] init] ;
	}
	return self ;
}

- (void) printToFile: (FILE *) outfp
{
	[self.rootSection printToFile: outfp withIndent: 0] ;
}

@end
