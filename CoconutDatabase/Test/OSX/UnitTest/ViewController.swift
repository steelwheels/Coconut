//
//  ViewController.swift
//  UnitTest
//
//  Created by Tomoo Hamada on 2021/05/07.
//

import CoconutData
import CoconutDatabase
import Contacts
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
		self.record()
	}

	private func authorize() {
		let db = CNContactDatabase.shared
		db.authorize(callback: {
			(_ granted: Bool) -> Void in
			if granted {
				NSLog("Authorization: OK")
				switch db.load(URL: nil) {
				case .ok:
					NSLog("Loading ... OK")
					db.forEach(callback: {
						(_ record: CNRecord) -> Void in
						if let crcd = record as? CNContactRecord {
							self.print(record: crcd)
						} else {
							NSLog("Load error: Not contact record")
						}
					})
				case .error(let err):
					NSLog("Load error: \(err.description)")
				@unknown default:
					NSLog("Load error: Unknown case")
				}
			} else {
				NSLog("Authorization: Error")
			}
		})
	}

	private func print(record rcd: CNContactRecord) {
		print(record: rcd, field: .familyName)
		print(record: rcd, field: .givenName)
	}

	private func print(record rcd: CNContactRecord, field fld: CNContactField) {
		if let val = rcd.value(ofField: fld.toName()) {
			if let str = val.toString() {
				NSLog("field:\(fld.toName()) ... \(str)")
			} else {
				NSLog("field:\(fld.toName()) ... \(val)")
			}
		}
	}

	private func table() {
		let db = CNContactDatabase.shared
		NSLog("record num = \(db.recordCount)")

		if let rec = db.record(at: 0) {
			for i in 0..<rec.fieldCount {
				if let title = rec.fieldName(at: i) {
					NSLog("title: \(title)")
				}
			}
		}

/*
		for ridx in 0..<rownum {
			for cidx in 0..<colnum {
				let val = table.value(columnIndex: .number(cidx), row: ridx)
				let str = val.toText().toStrings().joined()
				NSLog("(\(ridx), \(cidx)): \(str)")
			}
		}

		NSLog("**** Sort")
		let desc = CNSortDescriptors()
		desc.add(key: CNContactRecord.Property.familyName.toName(), ascending: true)
		table.sort(byDescriptors: desc)
		let propname = CNContactRecord.Property.familyName.toName()
		for ridx in 0..<rownum {
			let val = table.value(columnIndex: .title(propname), row: ridx)
			let str = val.toText().toStrings().joined()
			NSLog("(\(ridx): \(str)")
		}*/
	}

	private func record() {
		let db     = CNContactDatabase.shared
		guard let record = db.record(at: 0) else {
			NSLog("Failed to get record")
			return
		}
		printField(record: record, field: .identifier)
		printField(record: record, field: .contactType)
		printField(record: record, field: .namePrefix)
		printField(record: record, field: .givenName)
		printField(record: record, field: .familyName)
	}

	private func printField(record rcd: CNRecord, field fld: CNContactField) {
		if let val = rcd.value(ofField: fld.toName()) {
			printElement(elementName: fld.toName(), value: val)
		} else {
			printElement(elementName: fld.toName(), value: .nullValue)
		}
	}

	private func printElement(elementName name: String, value val: CNValue){
		let valstr = val.toText().toStrings().joined(separator: "\n")
		NSLog("element: \(name), value: \(valstr)")
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}

