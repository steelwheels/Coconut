/**
 * @file	CNFont.swift
 * @brief	Define CNFont class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)
	import Cocoa
	public typealias CNFont = NSFont
#else
	import UIKit
	public typealias CNFont = UIFont
#endif

public extension CNFont
{
	static let ClassName = "Font"

	static func fromValue(value val: CNValue) -> CNFont? {
		if let dict = val.toDictionary() {
			return fromValue(value: dict)
		} else {
			return nil
		}
	}

	static func fromValue(value val: Dictionary<String, CNValue>) -> CNFont? {
		if let nameval = val["name"], let sizeval = val["size"] {
			if let namestr = nameval.toString(), let sizenum = sizeval.toNumber() {
				return CNFont(name: namestr, size: CGFloat(sizenum.doubleValue))
			}
		}
		return nil
	}

	func toValue() -> CNStruct {
		let stype: CNStructType
		if let typ = CNStructTable.currentStructTable().search(byTypeName: CNFont.ClassName) {
			stype = typ
		} else {
			stype = CNStructType(typeName: "dummy")
		}
		#if os(OSX)
		let name: String   = self.familyName ?? "system"
		#else
		let name: String   = self.familyName
		#endif
		let size: NSNumber = NSNumber(floatLiteral: Double(self.pointSize))
		let values: Dictionary<String, CNValue> = [
			"name":	.stringValue(name),
			"size": .numberValue(size)
		]
		return CNStruct(type: stype, values: values)
	}
}
