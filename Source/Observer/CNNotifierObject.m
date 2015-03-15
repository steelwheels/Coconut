/**
 * @file	CNNotifierObject.m
 * @brief	Define CNNotifierObject class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNNotifierObject.h"

@implementation CNNotifierObject

- (instancetype) init
{
	if((self = [super init]) != nil){
		observerDictionary = [[NSMutableDictionary alloc] initWithCapacity: 8] ;
	}
	return self ;
}

- (void) dealloc
{
	NSArray * keys = [observerDictionary allKeys] ;
	for(NSString * key in keys){
		NSObject * obj = [observerDictionary objectForKey: key] ;
		[self removeObserver: obj forKeyPath: key] ;
	}
}

- (void) addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
	[super addObserver: observer forKeyPath: keyPath options: options context: context] ;
	[observerDictionary setValue: observer forKey: keyPath] ;
}

- (void) removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
	[super removeObserver: observer forKeyPath: keyPath] ;
	[observerDictionary removeObjectForKey: keyPath] ;
}
@end
