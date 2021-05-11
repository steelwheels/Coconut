/**
 * @file	UTNativeValueTable.swift
 * @brief	Test function for CNNativeValueTable datastructure
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testNativeValueTable(console cons: CNConsole) -> Bool
{
	let RECORD_NUM = 10
	let COLUMN_NUM =  5

	var result = true

	let table = CNNativeValueTable()

	/* setup table */
	for i in 0..<RECORD_NUM {
		let newrec = CNNativeValueRecord()
		for j in 0..<COLUMN_NUM {
			let val = CNNativeValue.numberValue(NSNumber(value: i*100 + j))
			if !newrec.appendValue(value: val) {
				cons.error(string: "[Error] Failed to append")
				result = false
			}
		}
		if !table.appendRecord(record: newrec){
			cons.error(string: "[Error] Failed to append")
			result = false
		}
	}

	/* print records */
	cons.print(string: "Print records\n")
	let recnum = table.numberOfRecords
	cons.print(string: "Record count = \(recnum)\n")
	if recnum != RECORD_NUM {
		cons.error(string: "[Error] Unexpected record count\n")
		result = false
	}
	for i in 0..<recnum {
		if let rec = table.record(at: i) {
			cons.print(string: "\(i): ")
			rec.forEach(callback: {
				(_ val: CNNativeValue) -> Void in
				let str = val.toText().toStrings(terminal: "").joined(separator: "\n")
				cons.print(string: "\(str) ")
			})
			cons.print(string: "\n")
		} else {
			cons.error(string: "[Error] No record\n")
			result = false
		}
	}

	/* print columns */
	printTable(table: table, console: cons)

	/* Expand table */
	cons.print(string: "Expand table\n")
	table.expand(horizontalSize: 15, verticalSize: 15)
	printTable(table: table, console: cons)

	return result
}

private func printTable(table tbl: CNNativeValueTable, console cons: CNConsole)
{
	cons.print(string: "Print table\n")
	tbl.forEachColumn(callback: {
		(_ col: CNNativeValueColumn) -> Void in
		col.forEach(callback: {
			(_ val: CNNativeValue) -> Void in
			let str = val.toText().toStrings(terminal: "").joined(separator: "\n")
			cons.print(string: "\(str) ")
		})
		cons.print(string: "\n")
	})
}
