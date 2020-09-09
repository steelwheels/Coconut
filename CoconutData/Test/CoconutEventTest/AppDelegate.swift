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
				let inurl = URL(fileURLWithPath: "/Users/tomoo/tmp_dir/a.txt")
				if let err = textedit.open(fileURL: inurl) {
					NSLog("Failed to make document: \(err.toString())")
				}
				return

				if let err = textedit.makeNewDocument() {
					NSLog("Failed to make document: \(err.toString())")
				} else {
					if let err = textedit.setContentOfFrontWindow(context: "Hello, world !!") {
						NSLog("Failed to set context: \(err.toString())")
					} else {
						switch textedit.contentOfFrontWindow() {
						case .ok(let str):
							NSLog("TEXT=\(str)")
							if let err = textedit.setNameOfFrontWindow(name: "CoconutEventTestText") {
								NSLog("Failed to set window name: \(err.toString())")
							} else {
								switch textedit.nameOfFrontWindow() {
								case .ok(let name):
									NSLog("FileName = \(name)")
									let savepath = NSHomeDirectory() + "/CoconutEventTest.txt"
									let saveurl  = URL(fileURLWithPath: savepath)
									if let err = textedit.save(fileURL: saveurl) {
										NSLog("Failed to save file: \(saveurl.path) -> \(err.toString())")
									} else {
										NSLog("save file done: \(saveurl.path)")
									}
									NSLog("open TextEdit.app -> done")
								case .error(let err):
									NSLog("Failed to get name: \(err.toString())")
								}
		 					}
						case .error(let err):
							NSLog("Failed to get context: \(err.toString())")
						}
					}
				}
			}
		} else {
			NSLog("Failed to launch text edit")
		}

		//let doc0 = CNRemoteApplication.index(number: 1, of: .document)
		//let sel0 = CNRemoteApplication.selectAllContext(of: doc0)
		//NSLog("desc=\(sel0)")
	}
}

