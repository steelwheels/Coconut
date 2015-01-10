/**
 * @file	CNTextVisitor.h
 * @brief	Define CNTextVisitor class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

#import <Foundation/Foundation.h>
#import "CNForwarders.h"

@interface CNTextVisitor : NSObject
- (id) acceptTextCompound: (CNTextCompound *) text withParameter: (id) param ;
- (id) acceptTextLine: (CNTextLine *) text withParameter: (id) param ;
- (id) acceptTextSection: (CNTextSection *) text withParameter: (id) param ;
@end
