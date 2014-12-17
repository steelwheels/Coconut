/**
 * @file	CNTextSection.h
 * @brief	Define CNTextSection class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNText.h"
#import "CNForwarders.h"

@interface CNTextSection : CNText <CNTextOperatiing>

/** Section title (will be nil) */
@property (strong, nonatomic) NSString *	sectionTitle ;
/** List of CNText */
@property (strong, nonatomic) CNList *		elementList ;

- (instancetype) init ;
- (instancetype) initWithTitle: (NSString *) title ;

- (void) appendChildText: (CNText *) element ;

@end
