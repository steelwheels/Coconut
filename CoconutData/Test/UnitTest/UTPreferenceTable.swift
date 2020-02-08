/**
 * @file	UTPreferenceTable.swift
 * @brief	Test function for CNPreferenceTable class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testPreferenceTable(console cons: CNConsole) -> Bool
{
	let table = CNPreferenceTable()

	let KEY0 = "key0"

	let listner0 = table.addObserver(forKey: KEY0, callback: {
		(_ val: Any) -> Void in
		if let intval = val as? Int {
			cons.print(string: "Observe: \(intval)\n")
		} else {
			cons.print(string: "Observe: nil\n")
		}
	})

	table.set(intValue: 123, forKey: KEY0)
	if let res = table.intValue(forKey: KEY0) {
		cons.print(string: "get -> \(res)\n")
	} else {
		cons.print(string: "get -> nil\n")
	}

	table.removeObserver(listner: listner0)

	testPreferenceTableSub(parameterTable: table, value: 0, console: cons)
	testPreferenceTableSub(parameterTable: table, value: 1, console: cons)
	testPreferenceTableSub(parameterTable: table, value: 2, console: cons)

	return true
}

private func testPreferenceTableSub(parameterTable table: CNPreferenceTable, value param: Int, console cons: CNConsole)
{
	let listner1 = table.addObserver(forKey: "KEY1", callback: {
		(_ val: Any) -> Void in
		if let intval = val as? Int {
			cons.print(string: "Observe: \(intval) at \(param)\n")
		} else {
			cons.print(string: "Observe: nil\n")
		}
	})

	table.set(intValue: 234 + param, forKey: "KEY1")
	if let res = table.intValue(forKey: "KEY1") {
		cons.print(string: "get -> \(res)\n")
	} else {
		cons.print(string: "get -> nil\n")
	}

	table.removeObserver(listner: listner1)
}

