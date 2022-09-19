/**
 * @file	testValueType.swift
 * @brief	Test function for CNValueSet class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testValueType(console cons: CNConsole) -> Bool
{
	let res0 = valueTypeTest(valueType: .numberType, console: cons)
	let res1 = valueTypeTest(valueType: .arrayType(.stringType), console: cons)
	let res2 = valueTypeTest(valueType: .enumType("Axis"), console: cons)
	let res3 = valueTypeTest(valueType: .dictionaryType(.enumType("Home")), console: cons)

	let result = res0 && res1 && res2 && res3
	return result
}

private func valueTypeTest(valueType vtype: CNValueType, console cons: CNConsole) -> Bool
{
	var result = false

	let encstr = vtype.encode()
	cons.print(string: "encode: \(encstr)\n")
	switch CNValueType.decode(code: encstr) {
	case .success(let revtype):
		cons.print(string: "reverse decoded: \(revtype.description)\n")
		switch vtype.compare(revtype) {
		case .orderedAscending, .orderedDescending:
			cons.print(string: "Error: Failed to decode/encode\n")
		case .orderedSame:
			cons.print(string: "Deecode and encode are succeeded\n")
			result = true
		}
	case .failure(let err):
		cons.print(string: "Error: \(err.toString())\n")
	}

	return result
}
