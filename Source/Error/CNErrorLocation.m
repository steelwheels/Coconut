/**
 * @file	CNErrorLocation.m
 * @brief	Extend NSErrorLocation class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNErrorLocation.h"

@implementation CNErrorLocation

@synthesize fileName, lineNo ;

- (instancetype) init
{
	if((self = [super init]) != nil){
		self.fileName = @"" ;
		self.lineNo = 0 ;
	}
	return self ;
}

@end
