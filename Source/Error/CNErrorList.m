/**
 * @file	CNErrorList.m
 * @brief	Extend NSErrorList class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNErrorList.h"
#import "CNError.h"
#import "CNList.h"

@implementation CNErrorList

@synthesize list ;

- (instancetype) init
{
	if((self = [super init]) != nil){
		self.list = [[CNList alloc] init] ;
	}
	return self ;
}

- (void) printToFile: (FILE *) outfp
{
	const struct CNListItem * item = self.list.firstItem ;
	for( ; item ; item = item->nextItem){
		NSError * err = (NSError *) CNObjectInListItem(item) ;
		[err printToFile: outfp] ;
	}
}

@end
