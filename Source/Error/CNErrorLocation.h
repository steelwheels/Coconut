/**
 * @file	CNErrorLocation.h
 * @brief	Extend NSErrorLocation class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>

@interface CNErrorLocation : NSObject

@property (strong, nonatomic) NSString *	fileName ;
@property (assign, nonatomic) NSUInteger	lineNo ;

- (instancetype) init ;

@end
