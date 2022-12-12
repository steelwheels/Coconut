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

	//let elm0: CNValue = .boolValue(true)
	//let elm1: CNValue = .boolValue(false)
	//let arr0: CNValue = .arrayValue([elm0, elm1])

	let set0val: Array<CNValue> = [
		.numberValue(NSNumber(integerLiteral: 0)),
		.numberValue(NSNumber(integerLiteral: 1)),
		.numberValue(NSNumber(integerLiteral: 2))
	]
	let set0: CNValue = .setValue(set0val)

	if set0.isSet {
		cons.print(string: "isSet ... OK\n")
	} else {
		cons.print(string: "isSet ... Error\n")
		result = false
	}

	let nset0 = set0.toPrimitiveValue()
	let set1  = CNValue.fromPrimiteValue(value: nset0)

	let txt = set1.toScript().toStrings().joined(separator: "\n")
	cons.print(string: "fromValue ... OK -> \(txt)\n")

	let elm10: CNValue = .numberValue(NSNumber(integerLiteral: 1))
	let elm11: CNValue = .numberValue(NSNumber(integerLiteral: 3))
	var arr12 = [elm10, elm11]
	CNInsertValue(target: &arr12, element: .numberValue(NSNumber(integerLiteral: 2)))
	let txt13 = CNValue.arrayValue(arr12).toScript().toStrings().joined(separator: "\n")
	cons.print(string: "Insert ... \(txt13)\n")

	let elm20: CNValue = .numberValue(NSNumber(integerLiteral: 1))
	let elm21: CNValue = .numberValue(NSNumber(integerLiteral: 2))
	let elm22: CNValue = .numberValue(NSNumber(integerLiteral: 3))
	let arr23 = [elm20, elm21, elm22]

	switch CNCompareValue(value0: .arrayValue(arr12), value1: .arrayValue(arr23)) {
	case .orderedAscending, .orderedDescending:
		cons.print(string: "compare ... Error\n")
		result = false
	case .orderedSame:
		cons.print(string: "compare ... OK\n")
	}

	return result
}

