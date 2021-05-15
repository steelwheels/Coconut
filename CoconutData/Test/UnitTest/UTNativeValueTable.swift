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
	var result = true

	let table = CNNativeValueTable()
	cons.print(string: "* Initial table\n")
	printTable(table: table, console: cons)

	cons.print(string: "* Add 1st item\n")
	table.setValue(column: 0, row: 0, value: .stringValue("0/0"))
	printTable(table: table, console: cons)

	cons.print(string: "* Add 2nd item\n")
	table.setValue(column: 1, row: 1, value: .stringValue("1/1"))
	printTable(table: table, console: cons)

	cons.print(string: "* Set 5x3 item\n")
	for col in 0..<5 {
		for row in 0..<3 {
			table.setValue(column: col, row: row, value: .stringValue("\(col)/\(row)"))
		}
	}
	printTable(table: table, console: cons)

	cons.print(string: "* Set columns\n")
	for col in 0..<6 {
		table.setTitle(column: col, title: "col\(col)")
	}
	printTable(table: table, console: cons)

	/* check index */
	if let idx = table.titleIndex(by: "col1") {
		if idx == 1 {
			cons.print(string: " -> index == 1\n")
		} else {
			cons.print(string: "Invalid index: \(idx)")
			result = false
		}
	} else {
		cons.print(string: "The title is NOT found")
		result = false
	}
	return result
}

private func printTable(table tbl: CNNativeValueTable, console cons: CNConsole)
{
	let rowcnt = tbl.rowCount
	let colcnt = tbl.columnCount
	cons.print(string:   "{\n"
			   + "  row-count:    \(rowcnt)\n"
			   + "  column-count: \(colcnt)\n")

	cons.print(string: "Title: ")
	for col in 0..<colcnt {
		let title = tbl.title(column: col)
		cons.print(string: "[\(title)]")
	}
	cons.print(string: "\n")

	for row in 0..<rowcnt {
		for col in 0..<colcnt {
			let val = tbl.value(column: col, row: row)
			let valstr = val.toText().toStrings(terminal: "").joined(separator: "\n")
			cons.print(string: valstr + ", ")
		}
		cons.print(string: "\n")
	}
	cons.print(string:   "}\n")
}

/*
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
*/

