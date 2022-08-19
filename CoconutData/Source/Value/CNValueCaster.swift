/*
 * @file	CNValueCaster.swift
 * @brief	Define CNValueCaster class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public func CNCastValue(from srcval: CNValue, to dsttyp: CNValueType) -> CNValue
{
	let result: CNValue
	switch srcval {
	case .numberValue(let num):
		switch dsttyp {
		case .enumType(let ename):
			let etable = CNEnumTable.currentEnumTable()
			if let etype = etable.search(byTypeName: ename) {
				if let eobj = etype.search(byValue: num.intValue) {
					result = .enumValue(eobj)
				} else {
					CNLog(logLevel: .error, message: "Unexpected raw value \(num.intValue) for \(etype.typeName)", atFunction: #function, inFile: #file)
					result = srcval
				}
			} else {
				CNLog(logLevel: .error, message: "Unknown enum type name: \(ename)", atFunction: #function, inFile: #file)
				result = srcval
			}
		default:
			result = srcval
		}
	default:
		result = srcval
	}
	return result
}

