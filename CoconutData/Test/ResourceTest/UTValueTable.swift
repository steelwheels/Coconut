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
	NSLog("UTValueTable")

	guard let baseurl = CNFilePath.URLForResourceDirectory(directoryName: "Data", subdirectory: nil, forClass: ViewController.self) else {
		return false
	}

	let base = CNValueCache(root: baseurl, parentCache: nil)
	switch base.load(relativePath: "adbook.json") {
	case .ok(_):
		break
	case .error(let err):
		NSLog("Error: \(err.toString())")
		return false
	}

	var result = true
	let liburl = CNFilePath.URLforUserLibraryDirectory()
	let cache  = CNValueCache(root: liburl, parentCache: base)

	let vtable = CNValueTable(path: ["persons"], valueCache: cache)
	NSLog("record count: \(vtable.recordCount)")
	NSLog("field names:  \(vtable.fieldNames)")

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

	/* Save the cache file */
	if cache.store(relativePath: "updated_adbook.json") {
		NSLog("cache store ... done")
	} else {
		NSLog("cache store ... failed")
		result = false
	}

	return result
}
