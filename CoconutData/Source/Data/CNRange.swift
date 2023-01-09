/**
 * @file	CNRange.swift
 * @brief	Define CNRange class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public extension NSRange
{
	static let InterfaceName = "RangeIF"

	static func allocateInterfaceType() -> CNInterfaceType {
		let ptypes: Dictionary<String, CNValueType> = [
			"location":	.numberType,
			"length":	.numberType
		]
		return CNInterfaceType(name: InterfaceName, base: nil, types: ptypes)
	}

	static func fromValue(value val: CNInterfaceValue) -> NSRange? {
		guard val.type.name == InterfaceName else {
			return nil
		}
		if let locval = val.get(name: "location"), let lenval = val.get(name: "length") {
			if let locnum = locval.toNumber(), let lennum = lenval.toNumber() {
				let loc = locnum.intValue
				let len = lennum.intValue
				return NSRange(location: loc, length: len)
			}
		}
		return nil
	}

	func toValue() -> CNInterfaceValue {
		let iftype: CNInterfaceType
		if let typ = CNInterfaceTable.currentInterfaceTable().search(byTypeName: NSRange.InterfaceName) {
			iftype = typ
		} else {
			CNLog(logLevel: .error, message: "No interface type: \"\(NSRange.InterfaceName)\"",
			      atFunction: #function, inFile: #file)
			iftype = CNInterfaceType.nilType
		}

		let locnum = NSNumber(integerLiteral: self.location)
		let lennum = NSNumber(integerLiteral: self.length)
		let ptypes: Dictionary<String, CNValue> = [
			"location" : .numberValue(locnum),
			"length"   : .numberValue(lennum)
		]
		return CNInterfaceValue(types: iftype, values: ptypes)
	}
}

