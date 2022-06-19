//
//  UTStorageTable.swift
//  ResourceTest
//
//  Created by Tomoo Hamada on 2021/12/31.
//

import CoconutData
import Foundation

public func UTStorageTable() -> Bool
{
	NSLog("*** UTStorageTable")
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
	let rec0_1 = CNStorageRecord(defaultFields: [
		"name": .stringValue("<no-name>"),
		"age":	.numberValue(NSNumber(integerLiteral: 0))
	])
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

private func allocateTable() -> (CNStorageTable, CNStorageTable)? {
	guard let srcfile = CNFilePath.URLForResourceFile(fileName: "adbook", fileExtension: "json", subdirectory: "Data", forClass: ViewController.self) else {
		NSLog("Failed to allocate source url")
		return nil
	}
	let cachefile = CNFilePath.URLForApplicationSupportFile(fileName: "adbook", fileExtension: "json", subdirectory: "Data")

	let srcdir   = srcfile.deletingLastPathComponent()
	let cachedir = cachefile.deletingLastPathComponent()
	let storage  = CNStorage(sourceDirectory: srcdir, cacheDirectory: cachedir, filePath: "adbook.json")
	switch storage.load() {
	case .success(_):
		let table0 = CNStorageTable(path: CNValuePath(identifier: nil, elements: [.member("persons")]), storage: storage)
		NSLog("record count [0]: \(table0.recordCount)")
		NSLog("field names  [0]: \(table0.fieldNames)")

		let table1 = CNStorageTable(path: CNValuePath(identifier: nil, elements: [.member("persons")]), storage: storage)
		NSLog("record count [1]: \(table1.recordCount)")
		NSLog("field names  [1]: \(table1.fieldNames)")

		return (table0, table1)
	case .failure(let err):
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
