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
static void
releaseAllListItem(struct CNListItem * firstitem, struct CNListItem * lastitem) ;

static NSLock *	sResourceLock  = nil ;

@implementation CNList

+ (void) initialize
{
	sResourceLock = [[NSLock alloc] init] ;
}

- (instancetype) init
{
	if((self = [super init]) != nil){
		itemCount = 0 ;
		firstItem = lastItem = nil ;
	}
	return self ;
}

- (void) dealloc
{
	releaseAllListItem(firstItem, lastItem) ;
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
	if(firstItem == NULL){
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
	if(firstItem == NULL){
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
		if(firstItem == NULL){
			lastItem = NULL ;
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
	releaseAllListItem(firstItem, lastItem) ;
	firstItem = lastItem = NULL ;
	itemCount = 0 ;
}

@end

static struct CNListItem *	s_list_item_pool = NULL ;

struct CNListItem *
allocateListItem(void)
{
	struct CNListItem * targitem ;
	[sResourceLock lock] ; {
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
	} [sResourceLock unlock] ;
	return targitem ;
}

static void
releaseListItem(struct CNListItem * dst)
{
	[sResourceLock lock] ; {
		if(dst->object){
			NSObject * dummyobj = (__bridge_transfer NSObject *) dst->object ;
			dummyobj = nil ; /* release object */
			dst->object = NULL ;
		}
		dst->nextItem = s_list_item_pool ;
		s_list_item_pool = dst ;
	} ; [sResourceLock unlock] ;
}

static void
releaseAllListItem(struct CNListItem * firstitem, struct CNListItem * lastitem)
{
	if(firstitem == NULL){
		return ;
	}
	@autoreleasepool {
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		dispatch_async(queue, ^{
			/* release contents */
			struct CNListItem * item ;
			for(item = firstitem ; item ; item = item->nextItem){
				NSObject * dummyobj = (__bridge_transfer NSObject *) item->object ;
				dummyobj = nil ; /* release object */
				item->object = NULL ;
			}
			[sResourceLock lock] ; {
				lastitem->nextItem = s_list_item_pool ;
				s_list_item_pool = firstitem ;
			} [sResourceLock unlock] ;
			//printf("[%s] %tu\n", __func__, CNCountOfFreeListItems()) ;
		});
	}
}

NSUInteger
CNCountOfFreeListItems(void)
{
	NSUInteger count = 0 ;
	[sResourceLock lock] ; {
		struct CNListItem * item = s_list_item_pool ;
		for( ; item ; item = item->nextItem){
			count++ ;
		}
	} ; [sResourceLock unlock] ;
	return count ;
}