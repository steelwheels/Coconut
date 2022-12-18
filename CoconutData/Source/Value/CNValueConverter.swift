/*
 * @file	CNValueConverter.swift
 * @brief	Extend CNValue to support converter
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

extension CNValue
{
	public static func dictionaryToValue(dictionary dict: Dictionary<String, CNValue>) -> CNValue? {
		var result: CNValue? = nil
		if let clsval = dict["class"] {
			if let clsname = clsval.toString() {
				switch clsname {
				case CNEnum.ClassName:
					if let eval = CNEnum.fromValue(value: dict) {
						result = .enumValue(eval)
					}
				case CNValueSet.ClassName:
					if let val = CNValueSet.fromValue(value: dict) {
						result = val
					}
				default:
					break
				}
			}
		}
		return result
	}
	
	public static func anyObjectToValue(object obj: AnyObject) -> CNValue {
		var result: CNValue
		if let _ = obj as? NSNull {
			result = CNValue.null
		} else if let val = obj as? NSNumber {
			if val.hasBoolValue {
				result = .boolValue(val.boolValue)
			} else {
				result = .numberValue(val)
			}
		} else if let val = obj as? NSString {
			result = .stringValue(val as String)
		} else if let val = obj as? Dictionary<String, AnyObject> {
			var newdict: Dictionary<String, CNValue> = [:]
			for (key, elm) in val {
				let child = anyObjectToValue(object: elm)
				newdict[key] = child
			}
			if let val = dictionaryToValue(dictionary: newdict){
				result = val
			} else {
				result = .dictionaryValue(newdict)
			}
		} else if let val = obj as? Array<AnyObject> {
			var newarr: Array<CNValue> = []
			for elm in val {
				let child = anyObjectToValue(object: elm)
				newarr.append(child)
			}
			result = .arrayValue(newarr)
		} else {
			result = .objectValue(obj as AnyObject)
		}
		return result
	}
	
	public func toAnyObject() -> AnyObject {
		let result: AnyObject
		switch self {
		case .boolValue(let val):
			result = NSNumber(booleanLiteral: val)
		case .numberValue(let val):
			result = val
		case .stringValue(let val):
			result = val as NSString
		case .enumValue(let val):
			let newval: CNValue = .dictionaryValue(val.toValue())
			result = newval.toAnyObject()
		case .objectValue(let val):
			result = val
		case .dictionaryValue(let dict):
			var newdict: Dictionary<String, AnyObject> = [:]
			for (key, elm) in dict {
				newdict[key] = elm.toAnyObject()
			}
			result = newdict as NSDictionary
		case .arrayValue(let arr):
			var newarr: Array<AnyObject> = []
			for elm in arr {
				newarr.append(elm.toAnyObject())
			}
			result = newarr as NSArray
		case .setValue(let arr):
			var newarr: Array<AnyObject> = []
			for elm in arr {
				newarr.append(elm.toAnyObject())
			}
			result = newarr as NSArray
		}
		return result
	}
}

