//
//  UTValueTable.swift
//  ResourceTest
//
//  Created by Tomoo Hamada on 2021/12/31.
//

import CoconutData
import Foundation

public func UTValueTable() -> Bool
{
	NSLog("*** UTValueTable")

	guard let baseurl = CNFilePath.URLForResourceDirectory(directoryName: "Data", subdirectory: nil, forClass: ViewController.self) else {
		return false
	}

	let base = CNValueStorage(packageDirectory: baseurl, filePath: "adbook.json", parentStorage: nil)
	switch base.load() {
	case .ok(_):
		break
	case .error(let err):
		NSLog("Error: \(err.toString())")
		return false
	}

	var result  = true
	let supurl  = CNFilePath.URLforApplicationSupportDirectory()
	NSLog("sup-cache: \(supurl.path)")
	let storage = CNValueStorage(packageDirectory: supurl, filePath: "updated_adbook.json", parentStorage: base)

	let vtable = CNValueTable(path: ["persons"], valueStorage: storage)
	NSLog("record count: \(vtable.recordCount)")
	NSLog("field names:  \(vtable.allFieldNames)")

	if let rec0 = vtable.record(at: 0) {
		if let nameval = rec0.value(ofField: "name") {
			let name = nameval.toText().toStrings().joined(separator: "\n")
			NSLog("rec0.name = \(name)")
		} else {
			NSLog("No name field")
			result = false
		}
	}
	if let rec1 = vtable.record(at: 1) {
		if rec1.setValue(value: .numberValue(NSNumber(integerLiteral: 12)), forField: "age") {
			if let ageval = rec1.value(ofField: "age") {
				switch ageval {
				case .numberValue(let num):
					NSLog("rec1.age = \(num.intValue)")
				default:
					NSLog("Unknown data: \(ageval.toText().toStrings().joined(separator: "\n"))")
					result = false
				}
			} else {
				NSLog("No age field")
				result = false
			}
		} else {
			NSLog("No record(1)")
		}
	}
	/* append record */
	let newrec = vtable.newRecord()
	if !newrec.setValue(value: .stringValue("sizuka"), forField: "name") {
		NSLog("Failed to set name to new record")
		result = false
	}
	if !newrec.setValue(value: .numberValue(NSNumber(integerLiteral: 11)), forField: "age") {
		NSLog("Failed to set age to new record")
		result = false
	}
	vtable.append(record: newrec)

	/* Save to the storage file */
	if storage.store() {
		NSLog("storage store ... done")
	} else {
		NSLog("storage store ... failed")
		result = false
	}

	return result
}
