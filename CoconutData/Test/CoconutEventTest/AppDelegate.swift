//
//  AppDelegate.swift
//  CoconutEventTest
//
//  Created by Tomoo Hamada on 2020/08/27.
//  Copyright © 2020 Steel Wheels Project. All rights reserved.
//

import CoconutData
import Cocoa

@NSApplicationMain
class AppDelegate: CNApplicationDelegate
{
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	override func applicationDidFinishLaunching(_ notification: Notification) {
		super.applicationDidFinishLaunching(notification)

		// open text edit
		NSLog("open TextEdit.app")
		if let runapp = CNRemoteApplication.launch(bundleIdentifier: "com.apple.TextEdit") {
			let textedit = CNRemoteApplication(application: runapp)
			if let err = textedit.activate() {
				NSLog("Failed to activate: \(err.toString())")
			} else {
				if let err = textedit.makeNewDocument() {
					NSLog("Failed to make document: \(err.toString())")
				} else {
					NSLog("open TextEdit.app -> done")
				}
			}
		} else {
			NSLog("Failed to launch text edit")
		}
	}
}

