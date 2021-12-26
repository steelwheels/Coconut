/**
 * @file	UTNativeValueTable.swift
 * @brief	Test function for CNValueTable datastructure
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testNativeValueTable(console cons: CNConsole) -> Bool
{
	let table = CNValueTable()
	cons.print(string: "* Initial table\n")
	printTable(table: table, console: cons)

	cons.print(string: "* Add 1st item\n")
	let res0 = setTable(table: table, column: "c0", row: 0, value: .stringValue("0/0"))
	printTable(table: table, console: cons)

	cons.print(string: "* Add 2nd item\n")
	let res1 = setTable(table: table, column: "c1", row: 1, value: .stringValue("1/1"))
	printTable(table: table, console: cons)

	cons.print(string: "* Set 5x3 item\n")
	var res2 = true
	for col in 0..<5 {
		for row in 0..<3 {
			if !setTable(table: table, column: "c\(col)", row: row, value: .stringValue("\(col)/\(row)")) {
				res2 = false
			}
		}
	}
	printTable(table: table, console: cons)

	/*
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
	//}*/

	return res0 && res1 && res2
}

private func setTable(table tbl: CNValueTable, column cname: String, row ridx: Int, value val: CNValue) -> Bool
{
	let rec: CNRecord
	if let r = tbl.record(at: ridx) {
		rec = r
	} else {
		let newrec = tbl.newRecord()
		tbl.append(record: newrec)
		rec = newrec
	}
	if rec.setValue(value: val, forField: cname) {
		return true
	} else {
		NSLog("Failed to set value")
		return false
	}
}

private func loadTest(source src: String, console cons: CNConsole) -> Bool {
	let newtable = CNValueTable()
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

private func printTable(table tbl: CNValueTable, console cons: CNConsole)
{
	let value = tbl.toValue()
	let text  = value.toText().toStrings().joined(separator: "\n")
	cons.print(string: "-----\n")
	cons.print(string: text)
	cons.print(string: "\n-----\n")
}

