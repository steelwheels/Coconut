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
class AppDelegate:  CNScriptableAppicationDelegate
{
	override func applicationDidFinishLaunching(_ aNotification: Notification) {
		super.applicationDidFinishLaunching(aNotification)
		// Insert code here to initialize your application
		let reg = NSScriptSuiteRegistry.shared()
		NSLog("SSR=\(reg)")
	}

	//func applicationWillTerminate(_ aNotification: Notification) {
	//	// Insert code here to tear down your application
	//}
}

