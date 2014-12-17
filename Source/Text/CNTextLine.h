/**
 * @file	CNTextLine.h
 * @brief	Define CNTextLine class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNText.h"

@interface CNTextLine : CNText <CNTextOperatiing>

@property (strong, nonatomic) NSString *	string ;

- (instancetype) initWithString: (NSString *) str ;

@end
