//
//  CoconutShell.h
//  CoconutShell
//
//  Created by Tomoo Hamada on 2018/04/21.
//  Copyright © 2018年 Steel Wheels Project. All rights reserved.
//

#import "TargetConditionals.h"
#if TARGET_OS_IPHONE
#	import <UIKit/UIKit.h>
#else
#	import <Cocoa/Cocoa.h>
#endif

//! Project version number for CoconutShell.
FOUNDATION_EXPORT double CoconutShellVersionNumber;

//! Project version string for CoconutShell.
FOUNDATION_EXPORT const unsigned char CoconutShellVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CoconutShell/PublicHeader.h>


