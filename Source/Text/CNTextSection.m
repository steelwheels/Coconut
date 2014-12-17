/**
 * @file	CNTextSection.m
 * @brief	Define CNTextSection class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNTextSection.h"
#import "CNList.h"

@implementation CNTextSection

@synthesize sectionTitle ;
@synthesize elementList ;

- (instancetype) init
{
	if((self = [super initWithElementKind: CNTextSectionElement]) != nil){
		self.sectionTitle = nil ;
		self.elementList = [[CNList alloc] init] ;
	}
	return self ;
}

- (instancetype) initWithTitle: (NSString *) title
{
	if((self = [super initWithElementKind: CNTextSectionElement]) != nil){
		self.sectionTitle = title ;
		self.elementList = [[CNList alloc] init] ;
	}
	return self ;
}

- (void) appendChildText: (CNText *) element
{
	[self.elementList addObject: element] ;
}

- (void) printToFile: (FILE *) outfp withIndent: (NSUInteger) indent
{
	if(self.sectionTitle != nil){
		[CNText printString: self.sectionTitle withIndent: indent toFile: outfp] ;
		indent++ ;
	}
	
	const struct CNListItem * item = self.elementList.firstItem ;
	for( ; item ; item = item->nextItem){
		CNText * element = (CNText *) CNObjectInListItem(item) ;
		NSUInteger childindent = indent ;
		switch(element.elementKind){
			case CNTextLineElement:				      break ;
			case CNTextSectionElement: childindent = indent + 1 ; break ;
		}
		[element printToFile: outfp withIndent: childindent] ;
	}
}

@end
