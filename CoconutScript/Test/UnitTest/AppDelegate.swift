//
//  AppDelegate.swift
//  UnitTest
//
//  Created by Tomoo Hamada on 2020/07/21.
//  Copyright © 2020 Steel Wheels Project. All rights reserved.
//

import CoconutData
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		let reg = NSScriptSuiteRegistry.shared()
		NSLog("SSR=\(reg)")
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func application(_ sender: NSApplication, delegateHandlesKey key: String) -> Bool {
		NSLog("asd: key=\(key)")
		return key == "preference"
	}

	public func preference() -> CNPreference {
		NSLog("app: preference")
		return CNPreference.shared
	}

	public override func value(forKey key: String) -> Any? {
		NSLog("forKey: \(key)")
		return super.value(forKey: key)
	}
}

