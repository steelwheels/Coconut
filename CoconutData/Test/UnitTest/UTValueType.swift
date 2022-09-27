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
	let etable = CNEnumTable.currentEnumTable()
	guard let etype = etable.search(byTypeName: "Axis") else {
		cons.print(string: "Error failed to get enum type for Axis")
		return false
	}

	let res0 = valueTypeTest(valueType: .numberType, console: cons)
	let res1 = valueTypeTest(valueType: .arrayType(.stringType), console: cons)
	let res2 = valueTypeTest(valueType: .enumType(etype), console: cons)
	let res3 = valueTypeTest(valueType: .dictionaryType(.enumType(etype)), console: cons)
	let res4 = valueTypeTest(valueType: .functionType(.voidType, [.numberType, .stringType]), console: cons)
	
	let result = res0 && res1 && res2 && res3 && res4
	return result
}

private func valueTypeTest(valueType vtype: CNValueType, console cons: CNConsole) -> Bool
{
	var result = false

	let encstr = CNValueType.encode(valueType: vtype)
	cons.print(string: "encode: \(encstr)\n")
	switch CNValueType.decode(code: encstr) {
	case .success(let revtype):
		let revcode = CNValueType.encode(valueType: revtype)
		cons.print(string: "reverse decoded: \(revcode)\n")
		switch CNValueType.compare(type0: vtype, type1: revtype) {
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
