/**
 * @file	CNNotifierObject.h
 * @brief	Define CNNotifierObject class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>

/**
 * @brief The object to send notification to observer
 */
@interface CNNotifierObject : NSObject
{
	NSMutableDictionary *		observerDictionary ;
}

- (instancetype) init ;
- (void) dealloc ;

- (void) addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context ;
- (void) removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath ;

@end
