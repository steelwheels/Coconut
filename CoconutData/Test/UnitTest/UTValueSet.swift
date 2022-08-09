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

	let elm0: CNValue = .boolValue(true)
	let elm1: CNValue = .boolValue(false)
	let arr0: CNValue = .arrayValue([elm0, elm1])

	let dict0: Dictionary<String, CNValue> = [
		"class":	.stringValue(CNValueSet.ClassName),
		"values":	arr0
	]
	if CNValueSet.isSet(dictionary: dict0) {
		cons.print(string: "isSet ... OK\n")
	} else {
		cons.print(string: "isSet ... Error\n")
		result = false
	}
	if let val = CNValueSet.fromValue(value: dict0) {
		let txt = val.toScript().toStrings().joined(separator: "\n")
		cons.print(string: "fromValue ... OK -> \(txt)\n")
	} else {
		cons.print(string: "fromValue ... Error\n")
		result = false
	}

	let elm10: CNValue = .numberValue(NSNumber(integerLiteral: 1))
	let elm11: CNValue = .numberValue(NSNumber(integerLiteral: 3))
	var arr12 = [elm10, elm11]
	CNValueSet.insert(target: &arr12, element: .numberValue(NSNumber(integerLiteral: 2)))
	let txt13 = CNValue.arrayValue(arr12).toScript().toStrings().joined(separator: "\n")
	cons.print(string: "Insert ... \(txt13)\n")

	let elm20: CNValue = .numberValue(NSNumber(integerLiteral: 1))
	let elm21: CNValue = .numberValue(NSNumber(integerLiteral: 2))
	let elm22: CNValue = .numberValue(NSNumber(integerLiteral: 3))
	let arr23 = [elm20, elm21, elm22]

	switch CNValueSet.compare(set0: arr12, set1: arr23) {
	case .orderedAscending, .orderedDescending:
		cons.print(string: "compare ... Error\n")
		result = false
	case .orderedSame:
		cons.print(string: "compare ... OK\n")
	}

	return result
}

