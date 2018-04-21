/*
 * @file	CoconutData.h
 * @brief	Objective-C header file for CoconutData Framework
 * @par Copyright
 *   Copyright (C) 2017, 2018 Steel Wheels Project
 */

#import "TargetConditionals.h"
#if TARGET_OS_IPHONE
#	import <UIKit/UIKit.h>
#else
#	import <Cocoa/Cocoa.h>
#endif

//! Project version number for CoconutData.
FOUNDATION_EXPORT double CoconutDataVersionNumber;

//! Project version string for CoconutData.
FOUNDATION_EXPORT const unsigned char CoconutDataVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CoconutData/PublicHeader.h>


