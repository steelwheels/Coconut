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
		let console = CNFileConsole()

		super.applicationDidFinishLaunching(aNotification)
		// Insert code here to initialize your application
		let reg = NSScriptSuiteRegistry.shared()
		NSLog("SSR=\(reg)")

		sdefTest(console: console)
	}

	private func sdefTest(console cons: CNConsole) {
		let sdefurl = URL(fileURLWithPath: "/System/Applications/Mail.app/Contents/Resources/Mail.sdef")
		let parser  = CNDefinitionParser()
		switch parser.parse(fileURL: sdefurl) {
		case .ok(let scrdef):
			cons.print(string: "Parse done: \(sdefurl.path)\n")
			let text = scrdef.toText()
			text.print(console: cons, terminal: "", indent: 0)
		case .error(let errs):
			for err in errs {
				cons.print(string: "[Error] \(err.toString())\n")
			}
		}
	}

	//func applicationWillTerminate(_ aNotification: Notification) {
	//	// Insert code here to tear down your application
	//}
}

