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
		terminalTest(console: console)
	}

	private func sdefTest(console cons: CNConsole) {
		let sdefurl = URL(fileURLWithPath: "/System/Applications/Mail.app/Contents/Resources/Mail.sdef")
		let parser  = CNDefinitionParser()
		switch parser.parse(fileURL: sdefurl) {
		case .ok(let scrdef):
			cons.print(string: "Parse done: \(sdefurl.path)\n")
			let text = scrdef.toText()
			text.print(console: cons, terminal: "", indent: 0)

			/* Dump as swift */
			let encoder = CNScriptCoder(console: cons)
			let txt     = encoder.encode(className: "MailClass", scriptDefinition: scrdef)
			txt.print(console: cons, terminal: "", indent: 0)
		case .error(let errs):
			for err in errs {
				cons.print(string: "[Error] \(err.toString())\n")
			}
		}
	}

	private func terminalTest(console cons: CNConsole) {
		if let app = CNRemoteTextEdit() {
			cons.print(string: "launch ... done: \(app)\n")
			if app.start() {
				cons.print(string: "start ... done\n")
				cons.print(string: "isFinishLaunching ... \(app.isFinishLaunching)\n")

				switch app.newDocument(withText: "Good morning") {
				case .ok(let responce):
					cons.print(string: "done\n")
					responce.dump(to: cons)

					/* Get document window name */
					var docname = "ReadMe"
					if let elm = responce.elementOfDirectParameter(keyword: CNAppleEventKeyword.selectData) {
						if let str = elm.toString() {
							cons.print(string: "Generated file name: \(str)\n")
							docname = str
						} else {
							elm.toText().print(console: cons, terminal: "")
						}
					}

					switch app.getDocuments(name: docname) {
					case .ok(let responce):
						cons.print(string: "done \(responce)\n")
						responce.dump(to: cons)
					case .error(let err):
						cons.print(string: "failed => \(err.localizedDescription)\n")
					}
				case .error(let err):
					cons.print(string: "Error (1): \(err.localizedDescription)\n")
				}
			} else {
				cons.print(string: "start ... failed\n")
			}
		} else {
			cons.print(string: "launch ... failed\n")
		}
	}

	//func applicationWillTerminate(_ aNotification: Notification) {
	//	// Insert code here to tear down your application
	//}
}

