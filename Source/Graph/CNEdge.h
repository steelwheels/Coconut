/**
 * @file	CNEdge.h
 * @brief	Define CNEdge class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>
#import "CNForwarders.h"

@interface CNEdge : NSObject

@property (weak, nonatomic) CNNode *		fromNode ;
@property (weak, nonatomic) CNNode *		toNode ;

- (id) init ;

@end
