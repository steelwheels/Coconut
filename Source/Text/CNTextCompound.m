/**
 * @file	CNTextCompound.m
 * @brief	Define CNTextCompound class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNTextCompound.h"
#import "CNList.h"

@implementation CNTextCompound

- (instancetype) init
{
	if((self = [super init]) != nil){
		self.headerString = nil ;
		self.middleString = nil ;
		self.tailString = nil ;
		self.elementList = [[CNList alloc] init] ;
	}
	return self ;
}

- (void) appendChildText: (CNText *) element
{
	[self.elementList addObject: element] ;
}

- (NSUInteger) lineCount
{
	NSUInteger result = 0 ;
	if(self.headerString){
		result++ ;
	}
	if(self.tailString){
		result++ ;
	}
	NSUInteger elmcount = [self.elementList count] ;
	if(self.middleString && elmcount >= 2){
		result += elmcount - 1 ; /* Count of middle strings */
	}
	const struct CNListItem * item = [self.elementList firstItem] ;
	for( ; item ; item = item->nextItem){
		CNText * childtext = (CNText *) CNObjectInListItem(item) ;
		result += [childtext lineCount] ;
	}
	return result ;
}

- (void) printToFile: (FILE *) outfp withIndent: (NSUInteger) indent
{
	if(self.headerString != nil){
		[CNText printString: self.headerString withIndent: indent toFile: outfp] ;
	}
	
	const struct CNListItem * item = [self.elementList firstItem] ;
	BOOL is1stitem = YES ;
	for( ; item ; item = item->nextItem){
		if(is1stitem){
			is1stitem = NO ;
		} else {
			if(self.middleString){
				[CNText printString: self.middleString withIndent: indent toFile: outfp] ;
			}
		}
		CNText * childtext = (CNText *) CNObjectInListItem(item) ;
		[childtext printToFile: outfp withIndent: indent+1] ;
	}
	
	if(self.tailString != nil){
		[CNText printString: self.tailString withIndent: indent toFile: outfp] ;
	}
}

@end
