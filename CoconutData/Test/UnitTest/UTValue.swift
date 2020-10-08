/**
 * @file	UTValue.swift
 * @brief	Test function for CNValue class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testValue(console cons: CNConsole) -> Bool
{
	let res0 = printValue(value: CNValue(booleanValue: true), expected: "true", console: cons)
	let res1 = printValue(value: CNValue(stringValue: "Hello, world"), expected: "Hello, world", console: cons)
	let res2 = testNativeValue(console: cons)
	return res0 && res1 && res2
}

private func printValue(value val: CNValue, expected exp: String, console cons: CNConsole) -> Bool
{
	let desc = val.description
	cons.print(string: "exp: \(exp) -> real: \(desc)\n")
	return desc == exp
}

private func testNativeValue(console cons: CNConsole) -> Bool
{
	let nval0 = CNNativeValue.numberValue(NSNumber(integerLiteral: 123))
	dumpValue(value: nval0, console: cons)
	return true
}

private func dumpValue(value val: CNNativeValue, console cons: CNConsole) {
	let typestr = val.valueType.toString()
	let valstr  = val.toText().toStrings(terminal: "").joined()
	cons.print(string: "nativeValue: type=\(typestr), value=\(valstr)\n")
}
