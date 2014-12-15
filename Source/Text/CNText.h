/**
 * @file	CNText.h
 * @brief	Define CNText class
 * @par Copyright
 *   Copyright (C) 2014 Steel Wheels Project
 */

#import <Foundation/Foundation.h>
#import "CNForwarders.h"

@interface CNText : NSObject

@property (strong, nonatomic) CNTextSection *	rootSection ;

- (instancetype) init ;
- (void) printToFile: (FILE *) outfp ;

@end
