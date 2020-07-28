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
	private var mProperties: Dictionary<String, Any>

	public override init() {
		mProperties = [:]
		super.init()
	}

	public override func setValue(_ value: Any?, forKey key: String) {
		if let v = value {
			mProperties[key] = v
		} else {
			mProperties.removeValue(forKey: key)
		}
	}

	public override func value(forKey key: String) -> Any? {
		if let val = mProperties[key] {
			return val
		} else {
			return super.value(forKey: key)
		}
	}

	#if os(OSX)
	open func application(_ sender: NSApplication, delegateHandlesKey key: String) -> Bool {
		NSLog("delegate: \(key)")
		if let _ = mProperties[key] {
			NSLog("true")
			return true
		} else {
			NSLog("false")
			return false
		}
	}
	#endif
}

