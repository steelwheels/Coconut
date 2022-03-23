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

	guard let (table0, table1) = allocateTable() else {
		NSLog("Failed to allocate table")
		return false
	}

	NSLog("**** Initial table 0")

	/* get record */
	guard let rec0_0 = table0.record(at: 0) else {
		NSLog("[Error] Failed to get record")
		return false
	}
	if let nameval = rec0_0.value(ofField: "name") {
		let name = nameval.toText().toStrings().joined(separator: "\n")
		NSLog("rec0_0.name = \(name)")
	} else {
		NSLog("[Error] No name field")
		result = false
	}

	/* add record */
	NSLog("**** Add record to table")
	let rec0_1 = CNRecord()
	result = rec0_1.setValue(value: .stringValue("Shizuka"), forField: "name") && result
	result = rec0_1.setValue(value: .numberValue(NSNumber(integerLiteral: 9)), forField: "age") && result
	table0.append(record: rec0_1)

	/* Search table from different table */
	NSLog("**+ Search other record")
	let rec1_0 = table1.search(value: .stringValue("Shizuka"), forField: "name")
	if rec1_0.count > 0 {
		printRecord(record: rec1_0[0])
	} else {
		NSLog("[Error] Failed to search")
		result = false
	}

	/* Save to the storage file */
	NSLog("**** Save the table")
	if table0.save() {
		NSLog("storage save ... done")
	} else {
		NSLog("storage save ... failed")
		result = false
	}

	return result
}

private func allocateTable() -> (CNValueTable, CNValueTable)? {
	guard let srcfile = CNFilePath.URLForResourceFile(fileName: "adbook", fileExtension: "json", subdirectory: "Data", forClass: ViewController.self) else {
		NSLog("Failed to allocate source url")
		return nil
	}

	let cachefile = CNFilePath.URLForApplicationSupportFile(fileName: "adbook", fileExtension: "json", subdirectory: "Data")
	guard FileManager.default.copyFileIfItIsNotExist(sourceFile: srcfile, destinationFile: cachefile) else {
		NSLog("Failed to copy value table")
		return nil
	}

	let srcdir   = srcfile.deletingLastPathComponent()
	let cachedir = cachefile.deletingLastPathComponent()
	let storage  = CNValueStorage(sourceDirectory: srcdir, cacheDirectory: cachedir, filePath: "adbook.json")
	switch storage.load() {
	case .ok(_):
		let table0 = CNValueTable(path: CNValuePath(elements: [.member("persons")]), valueStorage: storage)
		NSLog("record count [0]: \(table0.recordCount)")
		NSLog("field names  [0]:  \(table0.allFieldNames)")

		let table1 = CNValueTable(path: CNValuePath(elements: [.member("persons")]), valueStorage: storage)
		NSLog("record count [1]: \(table1.recordCount)")
		NSLog("field names  [1]:  \(table1.allFieldNames)")

		return (table0, table1)
	case .error(let err):
		NSLog("Failed to load storage: \(err.toString())")
		return nil
	}
}

private func printRecord(record rec: CNRecord){
	NSLog("record")
	for field in rec.fieldNames {
		if let val = rec.value(ofField: field) {
			NSLog(" - \(field): \(val.toText().toStrings().joined(separator: "\n"))")
		} else {
			NSLog(" - \(field): nil")
		}
	}
}
