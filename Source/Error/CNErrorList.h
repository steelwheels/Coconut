/**
 * @file	CNErrorList.h
 * @brief	Extend NSErrorList class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>
#import "CNForwarders.h"

@interface CNErrorList : NSObject

@property (strong, nonatomic) CNList *	list ;

- (instancetype) init ;

@end
