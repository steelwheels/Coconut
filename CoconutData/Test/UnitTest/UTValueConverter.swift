/**
 * @file	testValueConverter.swift
 * @brief	Test function for CNValueConverter class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testValueConverter(console cons: CNConsole) -> Bool
{
	let val0: CNValue = .boolValue(true)
	let res0 = valueConvert(value: val0, console: cons)

	let val1: CNValue = .numberValue(NSNumber(floatLiteral: 1.23))
	let res1 = valueConvert(value: val1, console: cons)

	let val2: CNValue = .stringValue("Hello, world")
	let res2 = valueConvert(value: val2, console: cons)

	let val3: CNValue
	let res3: Bool
	if let type3 = CNEnumTable.currentEnumTable().search(byTypeName: "Axis") {
		val3 = .enumValue(CNEnum(type: type3, member: "horizontal"))
		res3 = valueConvert(value: val3, console: cons)
	} else {
		cons.print(string: "[Error] Can not happen")
		val3 = CNValue.null
		res3 = false
	}

	let val4: CNValue = .arrayValue([val0, val1, val2, val3])
	let res4 = valueConvert(value: val4, console: cons)

	let val5: CNValue = .dictionaryValue([
		"a":val0, "b":val1, "c":val2, "d":val3
	])
	let res5 = valueConvert(value: val5, console: cons)

	return res0 && res1 && res2 && res3 && res4 && res5
}

private func valueConvert(value src: CNValue, console cons: CNConsole) -> Bool
{
	cons.print(string: "source: " + src.toScript().toStrings().joined(separator: "\n") + "\n")

	let v2o = CNValueToAnyObject()
	let obj = v2o.convert(value: src)

	let o2v = CNAnyObjecToValue()
	let rev = o2v.convert(anyObject: obj)

	cons.print(string: "reversed: " + rev.toScript().toStrings().joined(separator: "\n") + "\n")

	switch CNCompareValue(nativeValue0: src, nativeValue1: rev) {
	case .orderedSame:
		return true
	case .orderedAscending, .orderedDescending:
		return false
	}

