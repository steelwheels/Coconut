/**
 * @file	UTNotifierObject.m
 * @brief	Unit test function for CNNotifierObject class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "UnitTest.h"

@interface UTNotifierObject : CNNotifierObject
@property (assign, nonatomic) unsigned int	value ;
- (instancetype) init ;
@end

@implementation UTNotifierObject
@synthesize value ;
- (instancetype) init
{
	if((self = [super init]) != nil){
		self.value = 0 ;
	}
	return self ;
}
@end

@interface UTObserverObject : NSObject
-(void) observeValueForKeyPath: (NSString*)keyPath
		      ofObject: (id)object
		        change: (NSDictionary*)change
		       context: (void*)context ;
@end

@implementation UTObserverObject
-(void) observeValueForKeyPath: (NSString*)keyPath
		      ofObject: (id)object
			change: (NSDictionary*)change
		       context: (void*)context
{
	(void) change ; (void) context ;
	UTNotifierObject * notifier = object ;
	printf("observe: keypath %s, context %p", [keyPath UTF8String], context) ;
	printf("-> notifier value %u\n", notifier.value) ;
}
@end

void
testNotifierObject(void)
{
	UTNotifierObject *	notifier = [[UTNotifierObject alloc] init] ;
	UTObserverObject *	observer = [[UTObserverObject alloc] init] ;
	[notifier addObserver: observer forKeyPath: @"value" options: NSKeyValueObservingOptionNew context: NULL] ;
	
	notifier.value = 1 ;
	notifier.value = 1 ;
	notifier.value = 2 ;
}
