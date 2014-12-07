/**
 * @file	CNList.h
 * @brief	Define CNList class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>
#import "CNForwarders.h"

struct CNListItem {
	struct CNListItem *		nextItem ;
	void *				object ;
} ;

static inline NSObject *
CNObjectInListItem(const struct CNListItem * src)
{
	return (__bridge NSObject *) src->object ;
}

@interface CNList : NSObject
{
	NSUInteger		itemCount ;
	struct CNListItem *	firstItem ;
	struct CNListItem *	lastItem ;
}

- (id) init ;
- (void) dealloc ;

- (NSUInteger) count ;
- (const struct CNListItem *) firstItem ;
- (const struct CNListItem *) lastItem ;

- (void) addObject: (NSObject *) object ;
- (void) pushObject: (NSObject *) object ;
- (NSObject *) popObject ;
- (void) clear ;

@end

/* For debugging */
NSUInteger CNCountOfFreeListItems(void) ;
