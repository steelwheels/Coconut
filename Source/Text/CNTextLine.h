/**
 * @file	CNTextLine.h
 * @brief	Define CNTextLine class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import "CNTextElement.h"

@interface CNTextLine : CNTextElement <CNTextElementOperatiing>

@property (strong, nonatomic) NSString *	string ;

- (instancetype) initWithString: (NSString *) str ;

@end
