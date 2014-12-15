/**
 * @file	CNTextSection.h
 * @brief	Define CNTextSection class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNTextElement.h"
#import "CNForwarders.h"

@interface CNTextSection : CNTextElement <CNTextElementOperatiing>

/** List of CNTextElement */
@property (strong, nonatomic) CNList *	elementList ;

- (instancetype) init ;
- (void) appendElement: (CNTextElement *) element ;

@end
