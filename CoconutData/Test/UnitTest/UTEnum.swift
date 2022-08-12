/**
 * @file	UTEnum.swift
 * @brief	Test function for CNEnum class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testEnum(console cons: CNConsole) -> Bool
{
	cons.print(string: "*** Enum test\n")
	var result = true

	let etable = CNEnumTable.currentEnumTable()
	if let etype = etable.search(byTypeName: "LogLevel") {
		if let eobj = etype.allocate(name: "error") {
			cons.print(string: "LogLevel.error = \(eobj.typeName).\(eobj.memberName) = \(eobj.value)\n")
		} else {
			cons.error(string: "Enum LogLevel does not have errir member\n")
			result = false
		}
	} else {
		cons.error(string: "Enum LogLevel is not defined\n")
		result = false
	}

	return result
}

