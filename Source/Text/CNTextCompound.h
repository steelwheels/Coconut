/**
 * @file	CNTextCompound.h
 * @brief	Define CNTextCompound class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNText.h"
#import "CNForwarders.h"

@interface CNTextCompound : CNText <CNTextOperatiing>

@property (strong, nonatomic) NSString * headerString ;
@property (strong, nonatomic) NSString * middleString ;
@property (strong, nonatomic) NSString * tailString ;
@property (strong, nonatomic) CNList *	 elementList ;

- (instancetype) init ;
- (void) appendChildText: (CNText *) element ;

@end
