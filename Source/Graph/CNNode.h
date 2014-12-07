/**
 * @file	CNNode.h
 * @brief	Define CNNode class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>
#import "CNForwarders.h"

@interface CNNode : NSObject
{
	CNList *	allProducerEdges ;
	CNList *	allConsumerEdges ;
}

- (id) init ;

@end
