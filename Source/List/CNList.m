/**
 * @file	CNList.m
 * @brief	Define CNList class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNList.h"

static struct CNListItem *
allocateListItem(void) ;

static void
releaseListItem(struct CNListItem * dst) ;

@implementation CNList

- (id) init
{
	if((self = [super init]) != nil){
		itemCount = 0 ;
		firstItem = lastItem = nil ;
	}
	return self ;
}

- (void) dealloc
{
	[self clear] ;
}

- (NSUInteger) count
{
	return itemCount ;
}

- (const struct CNListItem *) firstItem
{
	return firstItem ;
}

- (const struct CNListItem *) lastItem
{
	return lastItem ;
}

- (void) addObject: (NSObject *) object
{
	struct CNListItem * newitem = allocateListItem() ;
	newitem->object = (__bridge_retained void *) object ;
	newitem->nextItem = NULL ;
	if(firstItem == nil){
		firstItem = lastItem = newitem ;
	} else {
		lastItem->nextItem = newitem ;
		lastItem = newitem ;
	}
	itemCount++ ;
}

- (void) pushObject: (NSObject *) object
{
	struct CNListItem * newitem = allocateListItem() ;
	newitem->object = (__bridge_retained void *) object ;
	if(firstItem == nil){
		newitem->nextItem = NULL ;
		firstItem = lastItem = newitem ;
	} else {
		newitem->nextItem = firstItem ;
		firstItem = newitem ;
	}
	itemCount++ ;
}

- (NSObject *) popObject
{
	if(firstItem){
		struct CNListItem * curitem = firstItem ;
		NSObject * curobj = (__bridge_transfer NSObject *) curitem->object ;
		curitem->object = NULL ;
		firstItem = curitem->nextItem ;
		if(firstItem == nil){
			lastItem = nil ;
		}
		itemCount-- ;
		releaseListItem(curitem) ;
		return curobj ;
	} else {
		return nil ;
	}
}

- (void) clear
{
	struct CNListItem * item = firstItem ;
	struct CNListItem * nextitem ;
	for( ; item ; item = nextitem){
		nextitem = item->nextItem ;
		releaseListItem(item) ;
	}
	firstItem = lastItem = NULL ;
	itemCount = 0 ;
}

@end

static struct CNListItem *	s_list_item_pool = NULL ;

static inline NSLock *
allocateLock(void)
{
	static NSLock *	s_resource_lock  = nil ;
	if(s_resource_lock == NULL){
		s_resource_lock = [[NSLock alloc] init] ;
	}
	return s_resource_lock ;
}

struct CNListItem *
allocateListItem(void)
{
	struct CNListItem * targitem ;
	NSLock * reslock = allocateLock() ;
	[reslock lock] ; {
		if(s_list_item_pool == NULL){
			struct CNListItem * newitems = malloc(sizeof(struct CNListItem) * 256) ;
			for(unsigned int i=0 ; i<256 ; i++){
				newitems[i].object = NULL ;
				newitems[i].nextItem = s_list_item_pool ;
				s_list_item_pool = &(newitems[i]) ;
			}
		}
		targitem = s_list_item_pool ;
		s_list_item_pool = targitem->nextItem ;
		targitem->nextItem = NULL ;
	} [reslock unlock] ;
	return targitem ;
}

static void
releaseListItem(struct CNListItem * dst)
{
	NSLock * reslock = allocateLock() ;
	[reslock lock] ; {
		if(dst->object){
			NSObject * dummyobj = (__bridge_transfer NSObject *) dst->object ;
			dummyobj = nil ; /* release object */
			dst->object = NULL ;
		}
		dst->nextItem = s_list_item_pool ;
		s_list_item_pool = dst ;
	} ; [reslock unlock] ;
}

NSUInteger
CNCountOfFreeListItems(void)
{
	NSUInteger count = 0 ;
	struct CNListItem * item = s_list_item_pool ;
	for( ; item ; item = item->nextItem){
		count++ ;
	}
	return count ;
}