/*
 * @file	CNValueConverter.swift
 * @brief	Extend CNValue to support converter
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public func CNDictionaryToValue(dictionary dict: Dictionary<String, CNValue>) -> CNValue? {
	guard let clsval = dict["class"] else {
		return nil
	}
	guard let clsname = clsval.toString() else {
		return nil
	}
	var result: CNValue? = nil
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
		/* Try to convert to interface value */
		if let ifval = CNInterfaceValue.fromValue(className: clsname, value: dict) {
			result = .interfaceValue(ifval)
		}
	}

	return result
}

open class CNValueToAnyObject
{
	public init() {
	}

	open func convert(value src: CNValue) -> AnyObject {
		let result: AnyObject
		switch src {
		case .boolValue(let val):
			result = NSNumber(booleanLiteral: val)
		case .numberValue(let val):
			result = val
		case .stringValue(let val):
			result = val as NSString
		case .enumValue(let val):
			result = convert(enumValue: val)
		case .objectValue(let val):
			result = val
		case .dictionaryValue(let dict):
			result = convert(dictionaryValue: dict)
		case .arrayValue(let arr):
			result = convert(arrayValue: arr)
		case .setValue(let arr):
			result = convert(arrayValue: arr)
		case .interfaceValue(let val):
			result = convert(dictionaryValue: val.values)
		}
		return result
	}

	open func convert(arrayValue src: Array<CNValue>) -> AnyObject {
		var newarr: Array<AnyObject> = []
		for elm in src {
			newarr.append(convert(value: elm))
		}
		return newarr as NSArray
	}

	open func convert(dictionaryValue src: Dictionary<String, CNValue>) -> AnyObject {
		var newdict: Dictionary<String, AnyObject> = [:]
		for (key, elm) in src{
			newdict[key] = convert(value: elm)
		}
		return newdict as NSDictionary
	}

	open func convert(enumValue src: CNEnum) -> AnyObject {
		return convert(dictionaryValue: src.toValue())
	}
}

open class CNAnyObjecToValue
{
	public init() {
	}

	open func convert(anyObject src: AnyObject) -> CNValue {
		var result: CNValue
		if let _ = src as? NSNull {
			result = CNValue.null
		} else if let val = src as? NSNumber {
			if val.hasBoolValue {
				result = .boolValue(val.boolValue)
			} else {
				result = .numberValue(val)
			}
		} else if let val = src as? NSString {
			result = .stringValue(val as String)
		} else if let val = src as? Dictionary<String, AnyObject> {
			result = convert(dictionaryObject: val)
		} else if let val = src as? Array<AnyObject> {
			result = convert(arrayObject: val)
		} else {
			result = .objectValue(src as AnyObject)
		}
		return result
	}

	open func convert(arrayObject src: Array<AnyObject>) -> CNValue {
		var newarr: Array<CNValue> = []
		for elm in src {
			newarr.append(convert(anyObject: elm))
		}
		return .arrayValue(newarr)
	}

	open func convert(dictionaryObject src: Dictionary<String, AnyObject>) -> CNValue {
		var newdict: Dictionary<String, CNValue> = [:]
		for (key, elm) in src {
			newdict[key] = convert(anyObject: elm)
		}
		let result: CNValue
		if let val = CNDictionaryToValue(dictionary: newdict){
			result = val
		} else {
			result = .dictionaryValue(newdict)
		}
		return result
	}
}


