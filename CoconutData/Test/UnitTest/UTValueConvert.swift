/**
 * @file	UTValueConvert.swift
 * @brief	Test function for CNValue class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testValueConvert(console cons: CNConsole) -> Bool
{
	let res0 = convertTest(value: .boolValue(true), console: cons)
	let res1 = convertTest(value: .numberValue(NSNumber(floatLiteral: 1.23)), console: cons)
	let res2 = convertTest(value: .stringValue("Hello, world !!"), console: cons)

	let dvals: Dictionary<String, CNValue> = [
		"a": CNValue.numberValue(NSNumber(floatLiteral: 1.1)),
		"b": CNValue.numberValue(NSNumber(floatLiteral: 2.2)),
		"c": CNValue.numberValue(NSNumber(floatLiteral: 3.3))
	]
	let res3 = convertTest(value: .dictionaryValue(dvals), console: cons)

	let res4: Bool
	if let etype = CNEnumTable.currentEnumTable().search(byTypeName: "Axis") {
		let eval  = CNEnum(type: etype, member: "horizontal")
		res4 = convertTest(value: .enumValue(eval), console: cons)
	} else {
		res4 = false
	}

	let avals: Array<CNValue> = [
		.numberValue(NSNumber(integerLiteral: 0)),
		.numberValue(NSNumber(integerLiteral: 1)),
		.numberValue(NSNumber(integerLiteral: 2))
	]
	let res5 = convertTest(value: .arrayValue(avals), console: cons)
	let res6 = convertTest(value: .setValue(avals), console: cons)

	let ptval = CGPoint(x: 10.0, y: 20.0).toValue()
	let res7  = convertTest(value: .structValue(ptval), console: cons)

	let rctval = CGRect(origin: CGPoint(x: 10, y: 20), size: CGSize(width: 30, height: 40)).toValue()
	let res8  = convertTest(value: .structValue(rctval), console: cons)

	return res0 && res1 && res2 && res3 && res4 && res5 && res6 && res7 && res8
}

private func convertTest(value src: CNValue, console cons: CNConsole) -> Bool
{
	cons.print(string: "source value: \(src.string), type:\(CNValueType.encode(valueType: src.valueType))\n")

	let obj = src.toNativeObject()
	cons.print(string: "result object: \(obj)\n")

	let dstval = CNValue.fromNativeObject(from: obj)
	cons.print(string: "result value: \(dstval.string), type:\(CNValueType.encode(valueType: dstval.valueType))\n")

	let result: Bool
	switch CNCompareValue(value0: src, value1: dstval){
	case .orderedSame:
		result = true
	case .orderedAscending, .orderedDescending:
		result = false
	}
	cons.print(string: "Convert: " + (result ? "success" : "fail") + "\n")
	return result
}

