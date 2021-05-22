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

	/* loadfunction */
	cons.print(string: "* Load test\n")
	if !loadTest(source: "{a: [10.0]}", console: cons) {
		result = false
	}
	if !loadTest(source: "[[10.0]]", console: cons) {
		result = false
	}
	if !loadTest(source: "[[\"a\", 10.0], [\"b\", 20.0]]", console: cons) {
		result = false
	}

	return result
}

private func loadTest(source src: String, console cons: CNConsole) -> Bool {
	let tbl = CNNativeValueTable()
	let result: Bool
	switch tbl.load(source: src) {
	case .ok:
		cons.print(string: "Source: \(src):\n")
		printTable(table: tbl, console: cons)
		result = true
	default:
		cons.print(string: "Parse error\n")
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
			   + "  column-count: \(colcnt)\n"
			   + "}\n")
	cons.print(string: "Title: ")
	for col in 0..<colcnt {
		let title = tbl.title(column: col)
		cons.print(string: "[\(title)]")
	}
	cons.print(string: "\n")

	for row in 0..<rowcnt {
		cons.print(string: " \(row): ")
		for col in 0..<colcnt {
			if col > 0 {
				cons.print(string: ", ")
			}
			let val = tbl.value(column: col, row: row)
			let valstr = val.toText().toStrings(terminal: "").joined(separator: "\n")
			cons.print(string: valstr)
		}
		cons.print(string: "\n")
	}

}

