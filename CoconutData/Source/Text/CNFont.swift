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
	static func fromValue(value val: Dictionary<String, CNValue>) -> CNFont? {
		if let nameval = val["name"], let sizeval = val["size"] {
			if let namestr = nameval.toString(), let sizenum = sizeval.toNumber() {
				return CNFont(name: namestr, size: CGFloat(sizenum.doubleValue))
			}
		}
		return nil
	}

	func toValue() -> Dictionary<String, CNValue> {
		#if os(OSX)
		let name: String   = self.familyName ?? "system"
		#else
		let name: String   = self.familyName
		#endif
		let size: NSNumber = NSNumber(floatLiteral: Double(self.pointSize))
		let result: Dictionary<String, CNValue> = [
			"name":	.stringValue(name),
			"size": .numberValue(size)
		]
		return result
	}
}
