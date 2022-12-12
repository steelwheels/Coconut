/*
 * @file	CNValueCaster.swift
 * @brief	Define CNValueCaster class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

/*
public func CNCastValue(from srcval: CNValue, to dsttyp: CNValueType) -> CNValue
{
	let eval: CNEnumType.Value
	switch srcval {
	case .numberValue(let num):
		eval = .intValue(num.intValue)
	case .stringValue(let str):
		eval = .stringValue(str)
	default:
		return srcval	// Can not cast to enum
	}

	let result: CNValue
	switch dsttyp {
	case .enumType(let etype):
		if let eobj = etype.search(byValue: eval) {
			result = .enumValue(eobj)
		} else {
			CNLog(logLevel: .error, message: "Unexpected raw value \(srcval.script) for \(etype.typeName)", atFunction: #function, inFile: #file)
			result = srcval	// Failed to cast to enum
		}
	default:
		return srcval	// Can not cast to enum
	}
	return result
}
*/

