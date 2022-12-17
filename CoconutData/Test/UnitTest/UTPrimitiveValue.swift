/**
 * @file	UTPrimitiveValue.swift
 * @brief	Test function for CNPrimitiveValue class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testPrimitiveValue(console cons: CNConsole) -> Bool
{
	let val0: CNValue = .boolValue(true)
	let res0 = convertValue(source: val0, console: cons)

	let val1: CNValue = .numberValue(NSNumber(floatLiteral: 1.23))
	let res1 = convertValue(source: val1, console: cons)

	let val2: CNValue = .numberValue(NSNumber(floatLiteral: -2.34))
	let res2 = convertValue(source: val2, console: cons)

	let val3: CNValue = .stringValue("Hello, world")
	let res3 = convertValue(source: val3, console: cons)

	let val4: CNValue = .dictionaryValue([
		"a": val0, "b": val1
	])
	let res4 = convertValue(source: val4, console: cons)

	let val5: CNValue = .arrayValue([
		val0, val1, val2
	])
	let res5 = convertValue(source: val5, console: cons)

	return res0 && res1 && res2 && res3 && res4 && res5
}

private func convertValue(source src: CNValue, console cons: CNConsole) -> Bool
{
	let srcdesc = src.toScript().toStrings().joined(separator: "\n")
	cons.print(string: "* source = \(srcdesc)\n")

	//cons.print(string: "* generate new primitive\n")
	let pval = CNPrimitiveValue.fromValue(src)

	//cons.print(string: "* revert the primitive\n")
	let rval = pval.toValue()

	let dstdesc = rval.toScript().toStrings().joined(separator: "\n")
	cons.print(string: "* newval = \(dstdesc)\n")

	let result: Bool
	switch CNCompareValue(nativeValue0: src, nativeValue1: rval) {
	case .orderedSame:
		result = true
	case .orderedAscending, .orderedDescending:
		cons.print(string: "[Error] Failed to convert/revert\n")
		result = false
	}
	return result
}
