/**
 * @file	CNRange.swift
 * @brief	Define CNRange class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public extension NSRange
{
	static let ClassName = "range"

	init?(value val: Dictionary<String, CNValue>) {
		if let locval = val["location"], let lenval = val["length"] {
			if let locnum = locval.toNumber(), let lennum = lenval.toNumber() {
				let loc = locnum.intValue
				let len = lennum.intValue
				self.init(location: loc, length: len)
				return
			}
		}
		return nil
	}

	func toValue() -> Dictionary<String, CNValue> {
		let locnum = NSNumber(integerLiteral: self.location)
		let lennum = NSNumber(integerLiteral: self.length)
		let result: Dictionary<String, CNValue> = [
			"class"    : .stringValue(NSRange.ClassName),
			"location" : .numberValue(locnum),
			"length"   : .numberValue(lennum)
		]
		return result
	}
}

