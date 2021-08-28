/**
 * @file	UTNativeValue.swift
 * @brief	Test function for CNNativeValue datastructure
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testNativeValue(console cons: CNConsole) -> Bool
{
	var result = true
	if !parseValue(string: "{}", console: cons){ result = false }
	if !parseValue(string: "[]", console: cons){ result = false }
	if !parseValue(string: "[10, 20]", console: cons){ result = false }
	if !parseValue(string: "[[10, 20], [\"a\", \"b\"]]", console: cons){ result = false }

	result = compareValues(console: cons) && result
	return result
}

private func parseValue(string str: String, console cons: CNConsole) -> Bool {
	cons.print(string: "source: \(str)\n")
	let parser = CNNativeValueParser()

	let result: Bool
	switch parser.parse(source: str) {
	case .ok(let val):
		let valstr = val.toText().toStrings().joined(separator: "\n")
		cons.print(string: "result: \(valstr)\n")
		result = true
	case .error(let err):
		cons.print(string: "result: [Error] \(err.description)")
		result = false
	}
	return result
}

private func compareValues(console cons: CNConsole) -> Bool {
	var result = true
	result = compareValue(value0: .nullValue, value1: .nullValue, expected: .orderedSame, console: cons) && result
	result = compareValue(value0: .numberValue(NSNumber(floatLiteral: 1.23)),
			      value1: .numberValue(NSNumber(floatLiteral: 1.23)),
			      expected: .orderedSame, console: cons) && result
	result = compareValue(value0: .numberValue(NSNumber(floatLiteral: 1.23)),
			      value1: .numberValue(NSNumber(floatLiteral: 12.3)),
			      expected: .orderedAscending, console: cons) && result
	result = compareValue(value0: .numberValue(NSNumber(booleanLiteral: false)),
			      value1: .numberValue(NSNumber(floatLiteral: 12.3)),
			      expected: .orderedAscending, console: cons) && result
	return result
}

private func compareValue(value0 val0: CNNativeValue, value1 val1: CNNativeValue, expected exp: ComparisonResult, console cons: CNConsole) -> Bool {
	cons.print(string: "Compare \(val0.toText().toStrings().joined()) and \(val1.toText().toStrings().joined()) ... ")
	let res = CNCompareValue(nativeValue0: val0, nativeValue1: val1)
	cons.print(string: " \(res.toString()) -> ")
	if res == exp {
		cons.print(string: "OK\n")
		return true
	} else {
		cons.print(string: "Error\n")
		return false
	}
}
