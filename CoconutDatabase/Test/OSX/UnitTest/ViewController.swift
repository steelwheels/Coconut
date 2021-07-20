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
		self.authorize()
		self.table()
	}

	private func authorize() {
		let db = CNContactDatabase.shared
		db.authorize(callback: {
			(_ granted: Bool) -> Void in
			if granted {
				NSLog("Authorization: OK")
				if db.load() {
					NSLog("Loading ... OK")
					db.forEach(callback: {
						(_ record: CNContactRecord) -> Void in
						self.print(record: record)
					})
				} else {
					NSLog("Loading ... Error")
				}
			} else {
				NSLog("Authorization: Error")
			}
		})
	}

	private func print(record rcd: CNContactRecord) {
		let ident  = rcd.identifier.toText().toStrings().joined(separator: "\n")
		let family = rcd.familyName.toText().toStrings().joined(separator: "\n")
		let given  = rcd.givenName.toText().toStrings().joined(separator: "\n")
		NSLog("ident=\(ident), family=\(family), given=\(given)")
	}

	private func table(){
		let table = CNContactTable()
		table.load(callback: {
			(_ result: Bool) -> Void in
			if result {
				NSLog("table: load ... OK")
			} else {
				NSLog("table: load ... NG")
			}
		})
		let colnum = table.columnCount
		let rownum = table.rowCount
		NSLog("column num = \(colnum), row num = \(rownum)")

		for cidx in 0..<colnum {
			let title = table.title(column: cidx)
			NSLog("title[\(cidx)]: \(title)")
		}

		for ridx in 0..<rownum {
			for cidx in 0..<colnum {
				let val = table.value(columnIndex: .number(cidx), row: ridx)
				let str = val.toText().toStrings().joined()
				NSLog("(\(ridx), \(cidx)): \(str)")
			}
		}

		NSLog("**** Sort")
		table.sort(byProperties: [.familyName], doAscending: false)
		let propname = CNContactRecord.Property.familyName.toName()
		for ridx in 0..<rownum {
			let val = table.value(columnIndex: .title(propname), row: ridx)
			let str = val.toText().toStrings().joined()
			NSLog("(\(ridx): \(str)")
		}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}

