/*
 * @file	UTMappingTable.swift
 * @brief	Test CNMappingTable class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import CoconutData
import Foundation

public func UTMappingTable() -> Bool
{
	NSLog("*** UTMappingTable")
	guard let table = allocateTable() else {
		return false
	}

	let maptable = CNMappingTable(sourceTable: table)
	NSLog("0) record count: \(maptable.recordCount)")

	maptable.setFilter(filterFunction: {
		(_ rec: CNRecord) -> Bool in return mapRecord(record: rec)
	})

	updateTable(table: table)
	NSLog("1) record count: \(maptable.recordCount)")

	return true
}

private func allocateTable() -> CNStorageTable? {
	guard let srcfile = CNFilePath.URLForResourceFile(fileName: "adbook", fileExtension: "json", subdirectory: "Data", forClass: ViewController.self) else {
		NSLog("Failed to allocate source url")
		return nil
	}
	let cachefile = CNFilePath.URLForApplicationSupportFile(fileName: "adbook", fileExtension: "json", subdirectory: "Data")

	let srcdir   = srcfile.deletingLastPathComponent()
	let cachedir = cachefile.deletingLastPathComponent()
	let storage  = CNStorage(sourceDirectory: srcdir, cacheDirectory: cachedir, filePath: "adbook.json")
	NSLog("storage = \(storage.toValue().toText().toStrings().joined(separator: "\n"))")
	switch storage.load() {
	case .success(_):
		let table = CNStorageTable(path: CNValuePath(identifier: nil, elements: [.member("persons")]), storage: storage)
		NSLog("record count: \(table.recordCount)")
		NSLog("field name:   \(table.fieldNames)")
		return table
	case .failure(let err):
		NSLog("Failed to load storage: \(err.toString())")
	}
	return nil
}

private func updateTable(table tbl: CNStorageTable)
{
	NSLog("* Add record to table")
	var result = true

	let rec0 = CNStorageRecord(defaultFields: [
		"name": .stringValue("<no-name>"),
		"age":	.numberValue(NSNumber(integerLiteral: 0))
	])
	result = rec0.setValue(value: .stringValue("Shizuka"), forField: "name") && result
	result = rec0.setValue(value: .numberValue(NSNumber(integerLiteral: 9)), forField: "age") && result
	tbl.append(record: rec0)

	let rec1 = CNStorageRecord(defaultFields: [
		"name": .stringValue("<no-name>"),
		"age":	.numberValue(NSNumber(integerLiteral: 0))
	])
	result = rec1.setValue(value: .stringValue("Suneo"), forField: "name") && result
	result = rec1.setValue(value: .numberValue(NSNumber(integerLiteral: 9)), forField: "age") && result
	tbl.append(record: rec1)
}

private func mapRecord(record rec: CNRecord) -> Bool {
	var name: String = "?"
	if let val = rec.value(ofField: "name") {
		name = val.toText().toStrings().joined(separator: "\n")
	}
	var age: Int = -1
	if let val = rec.value(ofField: "age") {
		if let num = val.toNumber() {
			age = num.intValue
		}
	}
	NSLog("* mapRecord: name: \(name), age: \(age)")
	return true
	//return (age == 9)
}
