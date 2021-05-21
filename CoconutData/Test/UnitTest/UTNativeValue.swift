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

	return result
}

private func parseValue(string str: String, console cons: CNConsole) -> Bool {
	cons.print(string: "source: \(str)\n")
	let parser = CNNativeValueParser()

	let result: Bool
	switch parser.parse(source: str) {
	case .ok(let val):
		let valstr = val.toText().toStrings(terminal: "").joined(separator: "\n")
		cons.print(string: "result: \(valstr)\n")
		result = true
	case .error(let err):
		cons.print(string: "result: [Error] \(err.description)")
		result = false
	}
	return result
}

