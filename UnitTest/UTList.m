/**
 * @file	UTList.m
 * @brief	Unit test function for CNList class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "UnitTest.h"

static void printFreeItemCount(void) ;
static void printList(CNList * list) ;
static void popItems(CNList * list) ;

void
testList(void)
{
	CNList * list = [[CNList alloc] init] ;
	
	puts("*** initial state") ;
	printFreeItemCount() ;
	
	puts("*** add 3 object") ;
	[list addObject: @"0"] ;
	[list addObject: @"1"] ;
	[list addObject: @"2"] ;
	
	printList(list) ;
	printFreeItemCount() ;
	
	[list clear] ;
	printFreeItemCount() ;
	
	puts("*** push 3 object ") ;
	[list pushObject: @"10"] ;
	[list pushObject: @"11"] ;
	[list pushObject: @"12"] ;
	//printList(list) ;
	popItems(list) ;
	printFreeItemCount() ;
}

static void
printFreeItemCount(void)
{
	printf("+ free items : %u\n", (unsigned int) CNCountOfFreeListItems()) ;
}

static void
printList(CNList * list)
{
	printf("count : %u\n", (unsigned int) [list count]) ;
	
	unsigned int idx = 0 ;
	const struct CNListItem * item = [list firstItem] ;
	for( ; item  ; item = item->nextItem){
		NSString * obj = (NSString *) CNObjectInListItem(item) ;
		printf("%u) %s\n", idx, [obj UTF8String]) ;
		idx++ ;
	}
}

static void
popItems(CNList * list)
{
	NSString * str ;
	while((str = (NSString *) [list popObject]) != nil){
		printf("poped %s\n", [str UTF8String]) ;
	}
}

