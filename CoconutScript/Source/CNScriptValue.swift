/**
 * @file	CNScriptValue.swift
 * @brief	Define CNScriptValue data
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

public enum CNScriptValue {
	case	boolValue(Bool)
	case	intValue(Int)
	case	floatValue(Double)
	case	dateValue(NSDate)
	case	urlValue(URL)
	case	dictionaryValue(Dictionary<String, CNScriptValue>)

	public func toObject() -> NSObject {
		let result: NSObject
		switch self {
		case .boolValue(let val):
			result = NSNumber(booleanLiteral: val)
		case .intValue(let val):
			result = NSNumber(integerLiteral: val)
		case .floatValue(let val):
			result = NSNumber(floatLiteral: val)
		case .dateValue(let val):
			result = val
		case .urlValue(let val):
			result = val as NSURL
		case .dictionaryValue(let dict):
			let result = NSMutableDictionary(capacity: 32)
			for (key, val) in dict {
				let obj = val.toObject()
				result.setValue(obj, forKey: key)
			}
			return result
		}
		return result
	}
}
