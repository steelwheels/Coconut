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
	let text0 =     "{\n"
		      + " headers: [\"t0\", \"t1\", \"t2\"],\n"
		      + " data: [\n"
		      + "  [1, 2, 3],\n"
		      + "  [4, 5, 6]\n"
		      + " ]\n"
		      + "}"
	if !loadTest(source: text0, console: cons) {
		result = false
	}

	let text1 =    "[\n"
		     + " {a:10, b:20, c: 30},\n"
		     + " {a:40, b:50, d: 60}\n"
		     + "]\n"
	if !loadTest(source: text1, console: cons) {
		result = false
	}
	//if !loadTest(source: "[[\"a\", 10.0], [\"b\", 20.0]]", console: cons) {
	//	result = false
	//}

	return result
}

private func loadTest(source src: String, console cons: CNConsole) -> Bool {
	let newtable = CNNativeValueTable()
	let result: Bool
	switch newtable.load(source: src) {
	case .ok:
		cons.print(string: "Source: \(src):\n")
		printTable(table: newtable, console: cons)
		result = true
	case .error(let err):
		cons.print(string: "Parse error: \(err.description)\n")
		result = false
	}
	return result
}

private func printTable(table tbl: CNNativeValueTable, console cons: CNConsole)
{
	let value = tbl.toNativeValue(format: tbl.format)
	let text  = value.toText().toStrings(terminal: "").joined(separator: "\n")
	cons.print(string: "-----\n")
	cons.print(string: text)
	cons.print(string: "\n-----\n")
}

