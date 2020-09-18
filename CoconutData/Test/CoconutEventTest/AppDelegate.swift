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

		self.controlTextEdit()
	}

	private func controlTextEdit() {
		// open text edit
		NSLog("open TextEdit.app")

		guard let textedit = CNTextEditApplication() else {
			NSLog("Failed to launch text edit")
			return
		}

		/*
		switch textedit.version() {
		case .ok(let desc):
			NSLog("version -> \(desc.description)")
		case .error(let err):
			NSLog("Failed to get version: \(err.toString())")
			return
		}*/

		switch textedit.activate() {
		case .ok(let desc):
			NSLog("activate -> \(desc.description)")
		case .error(let err):
			NSLog("Failed to get version: \(err.toString())")
			return
		}

		if let inurl = URL.openPanel(title: "Select .txt file", selection: .SelectFile, fileTypes: ["txt", "js"]) {
			switch textedit.open(fileURL: inurl) {
			case .ok(let desc):
				NSLog("open -> \(desc.description)")
			case .error(let err):
				NSLog("Failed to open: \(err.toString())")
				return
			}
		} else {
			NSLog("Failed to select file")
			return
		}

		/*
				NSLog("activate -> ack \(desc.description)")

				if let err = textedit.open(fileURL: inurl) {
					NSLog("Failed to make document: \(err.toString())")
				}

				if let err = textedit.close(fileURL: nil) {
					NSLog("Failed to close document: \(err.toString())")
				}

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


		//let doc0 = CNRemoteApplication.index(number: 1, of: .document)
		//let sel0 = CNRemoteApplication.selectAllContext(of: doc0)
		//NSLog("desc=\(sel0)")
*/
	}
}

