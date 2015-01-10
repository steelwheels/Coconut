/**
 * @file	CNTextSection.m
 * @brief	Define CNTextSection class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNTextSection.h"
#import "CNTextVisitor.h"
#import "CNList.h"

@implementation CNTextSection

@synthesize sectionTitle ;
@synthesize elementList ;

- (instancetype) init
{
	if((self = [super init]) != nil){
		self.sectionTitle = nil ;
		self.elementList = [[CNList alloc] init] ;
	}
	return self ;
}

- (instancetype) initWithTitle: (NSString *) title
{
	if((self = [super init]) != nil){
		self.sectionTitle = title ;
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
	if(self.sectionTitle){
		result++ ;
	}
	const struct CNListItem * item = self.elementList.firstItem ;
	for( ; item ; item = item->nextItem){
		CNText * element = (CNText *) CNObjectInListItem(item) ;
		result += [element lineCount] ;
	}
	return result ;
}

- (id) acceptVisitor: (CNTextVisitor *) visitor withParameter: (id) param
{
	return [visitor acceptTextSection: self withParameter: param] ;
}

- (void) printToFile: (FILE *) outfp withIndent: (NSUInteger) indent
{
	NSUInteger nextindent = indent ;
	if(self.sectionTitle != nil){
		[CNText printString: self.sectionTitle withIndent: indent toFile: outfp] ;
		nextindent++ ;
	}
	
	const struct CNListItem * item = self.elementList.firstItem ;
	for( ; item ; item = item->nextItem){
		CNText * element = (CNText *) CNObjectInListItem(item) ;
		[element printToFile: outfp withIndent: nextindent] ;
	}
}

@end
