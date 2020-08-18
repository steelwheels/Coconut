/**
 * @file	CNApplicationDelegate.swift
 * @brief	Define CNApplicationDelegate class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif

#if os(OSX)
public typealias CNApplicationBase	   	= NSApplication
public typealias CNApplicationDelegateBase 	= NSApplicationDelegate
public typealias CNApplicationDelegateSuper	= NSObject
#else
public typealias CNApplicationBase	   	= UIApplication
public typealias CNApplicationDelegateBase 	= UIApplicationDelegate
public typealias CNApplicationDelegateSuper	= UIResponder
#endif

open class CNApplicationDelegate: CNApplicationDelegateSuper, CNApplicationDelegateBase
{

	public override init() {
		super.init()
	}

	open func applicationDidFinishLaunching(_ notification: Notification) {
		#if os(OSX)
			NSLog("Setup event manager")
			let mgr = CNAppleEventManager.shared()
			mgr.setup()
		#endif
	}
}

