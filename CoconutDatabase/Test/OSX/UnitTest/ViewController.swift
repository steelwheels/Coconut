//
//  ViewController.swift
//  UnitTest
//
//  Created by Tomoo Hamada on 2021/05/07.
//

import CoconutData
import CoconutDatabase
import Cocoa

class ViewController: NSViewController
{
	override func viewDidLoad() {
		super.viewDidLoad()

		CNPreference.shared.systemPreference.logLevel = .detail
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		let db = CNContactDatabase.shared
		db.authorize(callback: {
			(_ granted: Bool) -> Void in
			if granted {
				NSLog("Authorization: OK")
				if db.load() {
					NSLog("Loading ... OK")
				} else {
					NSLog("Loading ... Error")
				}
			} else {
				NSLog("Authorization: Error")
			}
		})
	}

	private func print(record rcd: CNContactRecord) {
		let ident = rcd.identifier.toText().toStrings().joined(separator: "\n")
		let fname = rcd.familyName.toText().toStrings().joined(separator: "\n")
		NSLog("ident=\(ident), fname=\(fname)")
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}

