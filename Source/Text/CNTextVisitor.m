/**
 * @file	CNTextVisitor.m
 * @brief	Define CNTextVisitor class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

#import "CNTextVisitor.h"

@implementation CNTextVisitor

- (id) acceptTextCompound: (CNTextCompound *) text withParameter: (id) param
{
	(void) text ; (void) param ;
	return nil ;
}

- (id) acceptTextLine: (CNTextLine *) text withParameter: (id) param
{
	(void) text ; (void) param ;
	return nil ;
}

- (id) acceptTextSection: (CNTextSection *) text withParameter: (id) param
{
	(void) text ; (void) param ;
	return nil ;
}

@end
