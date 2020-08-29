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

	#if os(OSX)
	open func application(_ sender: NSApplication, delegateHandlesKey key: String) -> Bool {
		NSLog("Access to the delegateHandlesKey: \(key)")
		let mgr = CNAppleEventManager.shared()
		return mgr.hasProperty(named: key)
	}

	open override func value(forKey key: String) -> Any? {
		NSLog("value forKey: \(key)")
		let mgr = CNAppleEventManager.shared()
		return mgr.property(forKey: key)
	}

	open override func setValue(_ value: Any?, forKey key: String) {
		NSLog("set value forKey: \(key)")
		let mgr = CNAppleEventManager.shared()
		mgr.setProperty(value, forKey: key)
	}
	#endif
}

