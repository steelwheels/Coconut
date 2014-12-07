/**
 * @file	CNGraph.m
 * @brief	Define CNGraph class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNGraph.h"
#import "CNNode.h"
#import "CNEdge.h"
#import "CNList.h"

@implementation CNGraph

- (id) init
{
	if((self = [super init]) != nil){
		allNodes = [[CNList alloc] init] ;
		allEdges = [[CNList alloc] init] ;
	}
	return self ;
}

- (CNNode *) newNode
{
	CNNode * node = [[CNNode alloc] init] ;
	[allNodes addObject: node] ;
	return node ;
}

- (CNEdge *) newEdge
{
	CNEdge * edge = [[CNEdge alloc] init] ;
	[allEdges addObject: edge] ;
	return edge ;
}

@end
