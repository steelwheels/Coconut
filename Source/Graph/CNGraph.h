/**
 * @file	CNGraph.h
 * @brief	Define CNGraph class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>
#import "CNForwarders.h"

@interface CNGraph : NSObject
{
	CNList *	allNodes ;
	CNList *	allEdges ;
}

- (id) init ;

- (CNNode *) newNode ;
- (CNEdge *) newEdge ;

@end
