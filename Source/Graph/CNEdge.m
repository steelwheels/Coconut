/**
 * @file	CNEdge.m
 * @brief	Define CNEdge class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNEdge.h"

@implementation CNEdge

@synthesize fromNode ;
@synthesize toNode ;

- (id) init
{
	if((self = [super init]) != nil){
		self.fromNode = nil ;
		self.toNode = nil ;
	}
	return self ;
}

@end
