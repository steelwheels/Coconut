/**
 * @file	testValueSet.swift
 * @brief	Test function for CNValueSet class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testValueSet(console cons: CNConsole) -> Bool
{
	var result = true

	let set0 = CNValueSet()
	cons.print(string: "* initial set\n")
	printValues(values: set0.values, console: cons)

	cons.print(string: "* insert to set\n")
	insert(set0, 1)
	insert(set0, 5)
	insert(set0, 3)
	printValues(values: set0.values, console: cons)

	cons.print(string: "* check context of the set\n")
	if set0.has(value: intToValue(1)) {
		cons.print(string: "has 1 ... OK\n")
	} else {
		cons.print(string: "not have 1 ... Error\n")
		result = false
	}

	cons.print(string: "* check context of the set\n")
	if set0.has(value: intToValue(2)) {
		cons.print(string: "has 2 ... Error\n")
		result = false
	} else {
		cons.print(string: "not have 2 ... OK\n")
	}

	cons.print(string: "* remove from set\n")
	if remove(set0, 3) {
		cons.print(string: "remove 3 ... OK\n")
	} else {
		cons.print(string: "failed to remove 3 ... Error\n")
		result = false
	}
	printValues(values: set0.values, console: cons)

	return result
}

private func intToValue(_ val: Int) -> CNValue {
	return CNValue.numberValue(NSNumber(integerLiteral: val))
}

private func insert(_ dst: CNValueSet, _ val: Int){
	dst.insert(value: intToValue(val))
}

private func remove(_ dst: CNValueSet, _ val: Int) -> Bool {
	return dst.remove(value: intToValue(val))
}

private func has(_ src: CNValueSet, _ val: Int) -> Bool {
	return src.has(value: intToValue(val))
}

private func printValues(values vals: Array<CNValue>, console cons: CNConsole){
	cons.print(string: "[")
	for val in vals {
		let txt = val.toText().toStrings().joined(separator: "\n")
		cons.print(string: txt)
		cons.print(string: ", ")
	}
	cons.print(string: "]\n")
}
