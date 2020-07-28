//
//  AppDelegate.swift
//  UnitTest
//
//  Created by Tomoo Hamada on 2020/07/21.
//  Copyright © 2020 Steel Wheels Project. All rights reserved.
//

import CoconutScript
import CoconutData
import Cocoa

@NSApplicationMain
class AppDelegate: CNApplicationDelegate
{
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		self.setScriptValue(value: .colorValue(.black), forKey: "foregroundColor")
		self.setScriptValue(value: .colorValue(.white), forKey: "backgroundColor")

		// Insert code here to initialize your application
		let reg = NSScriptSuiteRegistry.shared()
		NSLog("SSR=\(reg)")
	}

	@inline(__always)  private func setScriptValue(value val: CNScriptValue, forKey key: String) {
		super.setValue(val.toObject(), forKey: key)
	}

	//func applicationWillTerminate(_ aNotification: Notification) {
	//	// Insert code here to tear down your application
	//}
}

