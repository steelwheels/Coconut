/**
 * @file	CNNode.m
 * @brief	Define CNNode class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNNode.h"
#import "CNList.h"

@implementation CNNode

- (id) init
{
	if((self = [super init]) != nil){
		allProducerEdges = [[CNList alloc] init] ;
		allConsumerEdges = [[CNList alloc] init] ;
	}
	return self ;
}

@end
