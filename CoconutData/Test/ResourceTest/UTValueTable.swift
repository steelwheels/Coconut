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
	var result = true

	guard let srcfile = CNFilePath.URLForResourceFile(fileName: "adbook", fileExtension: "json", subdirectory: "Data", forClass: ViewController.self) else {
		NSLog("Failed to allocate source url")
		return false
	}

	let cachefile = CNFilePath.URLForApplicationSupportFile(fileName: "adbook", fileExtension: "json", subdirectory: "Data")
	
	guard FileManager.default.copyFileIfItIsNotExist(sourceFile: srcfile, destinationFile: cachefile) else {
		NSLog("Failed to copy value table")
		return false
	}

	let srcdir   = srcfile.deletingLastPathComponent()
	let cachedir = cachefile.deletingLastPathComponent()
	let storage  = CNValueStorage(sourceDirectory: srcdir, cacheDirectory: cachedir, filePath: "adbook.json")
	switch storage.load() {
	case .ok(_):
		break
	case .error(let err):
		NSLog("Error: \(err.toString())")
		return false
	}

	let vtable = CNValueTable(path: CNValuePath(elements: [.member("persons")]), valueStorage: storage)
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
	let newrec = CNRecord()
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
