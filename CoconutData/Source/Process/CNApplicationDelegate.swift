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
public typealias CNApplicationDelegateSuper	= CNObject
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
		/* Setup default objects */
		super.setValue(CNPreference.shared, forKey: "preference")
	}

	//open func application(_ sender: CNApplicationBase, delegateHandlesKey key: String) -> Bool {
	//	return isBuiltinKey(key: key)
	//}

	//private func isBuiltinKey(key str: String) -> Bool {
	//	let result: Bool
	//	switch str {
	//	case "preference":	result = true
	//	default:		result = false
	//	}
	//	return result
	//}
}

