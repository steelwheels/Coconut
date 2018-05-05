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
	return res0 && res1
}

private func printValue(value val: CNValue, expected exp: String, console cons: CNConsole) -> Bool
{
	let desc = val.description
	console.print(string: "exp: \(exp) -> real: \(desc)\n")
	return desc == exp
}

