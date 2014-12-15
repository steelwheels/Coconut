/**
 * @file	CNTextSection.m
 * @brief	Define CNTextSection class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNTextSection.h"
#import "CNList.h"

@implementation CNTextSection

@synthesize elementList ;

- (instancetype) init
{
	if((self = [super initWithElementKind: CNTextSectionElement]) != nil){
		self.elementList = [[CNList alloc] init] ;
	}
	return self ;
}

- (void) appendElement: (CNTextElement *) element
{
	[self.elementList addObject: element] ;
}

- (void) printToFile: (FILE *) outfp withIndent: (NSUInteger) indent
{
	const struct CNListItem * item = self.elementList.firstItem ;
	for( ; item ; item = item->nextItem){
		CNTextElement * element = (CNTextElement *) CNObjectInListItem(item) ;
		switch(element.elementKind){
			case CNTextLineElement: {
				[element printToFile: outfp withIndent: indent  ] ;
			} break ;
			case CNTextSectionElement: {
				[element printToFile: outfp withIndent: indent+1] ;
			} break ;
		}
	}
}

@end
