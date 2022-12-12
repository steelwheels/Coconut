/*
 * @file	CNValue.swift
 * @brief	Define CNValue class
 * @par Copyright
 *   Copyright (C) 2017-2021 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public enum CNValue
{
	case boolValue(_ val: Bool)
	case numberValue(_ val: NSNumber)
	case stringValue(_ val: String)
	case enumValue(_ val: CNEnum)
	case dictionaryValue(_ val: Dictionary<String, CNValue>)
	case structValue(_ val: CNStruct)
	case arrayValue(_ val: Array<CNValue>)
	case setValue(_ val: Array<CNValue>)	// Sorted in ascending order
	case objectValue(_ val: AnyObject)
	//case functionValue(_ val: (_ params: Array<CNValue>) -> CNValue)

	public var valueType: CNValueType { get {
		let result: CNValueType
		switch self {
		case .boolValue(_):
			result = .boolType
		case .numberValue(_):
			result = .numberType
		case .stringValue(_):
			result = .stringType
		case .dictionaryValue(let dict):
			let elmtype: CNValueType
			if let elmval = dict.values.first {
				elmtype = elmval.valueType
			} else {
				elmtype = .anyType
			}
			result = .dictionaryType(elmtype)
		case .structValue(let sval):
			if let stype = CNStructTable.currentStructTable().search(byTypeName: sval.type.typeName) {
				result = .structType(stype)
			} else {
				CNLog(logLevel: .error, message: "Unknow struct type name: \(sval.type.typeName)", atFunction: #function, inFile: #file)
				result = .anyType
			}
		case .arrayValue(let vals):
			let elmtype: CNValueType
			if vals.count > 0 {
				elmtype = vals[0].valueType
			} else {
				elmtype = .anyType
			}
			result = .arrayType(elmtype)
		case .setValue(let vals):
			let elmtype: CNValueType
			if vals.count > 0 {
				elmtype = vals[0].valueType
			} else {
				elmtype = .setType(.anyType)
			}
			result = .setType(elmtype)
		case .objectValue(let obj):
			let name = String(describing: type(of: obj))
			result = .objectType(name)
		case .enumValue(let eobj):
			if let etype = eobj.enumType {
				result = .enumType(etype)
			} else {
				CNLog(logLevel: .error, message: "Failed to get enum type (Can not happen)", atFunction: #function, inFile: #file)
				result = .anyType
			}
		}
		return result
	}}

	public static var null: CNValue { get {
		return CNValue.objectValue(NSNull())
	}}

	public var isBool: Bool { get {
		let result: Bool
		switch self {
		case .boolValue(_):		result = true
		default:			result = false
		}
		return result
	}}

	public func toBool() -> Bool? {
		let result: Bool?
		switch self {
		case .boolValue(let val):	result = val
		default:			result = nil
		}
		return result
	}

	public var isNumber: Bool { get {
		let result: Bool
		switch self {
		case .numberValue(_):		result = true
		default:			result = false
		}
		return result
	}}

	public func toNumber() -> NSNumber? {
		let result: NSNumber?
		switch self {
		case .numberValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public var isString: Bool { get {
		let result: Bool
		switch self {
		case .stringValue(_):		result = true
		default:			result = false
		}
		return result
	}}

	public func toString() -> String? {
		let result: String?
		switch self {
		case .stringValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public var isEnum: Bool { get {
		let result: Bool
		switch self {
		case .enumValue(_):		result = true
		default:			result = false
		}
		return result
	}}

	public func toEnum() -> CNEnum? {
		let result: CNEnum?
		switch self {
		case .enumValue(let eval):		result = eval
		default:				result = nil
		}
		return result
	}

	public var isDictionary: Bool { get {
		let result: Bool
		switch self {
		case .dictionaryValue(_):	result = true
		default:			result = false
		}
		return result
	}}

	public func toDictionary() -> Dictionary<String, CNValue>? {
		let result: Dictionary<String, CNValue>?
		switch self {
		case .dictionaryValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public var isStruct: Bool { get {
		let result: Bool
		switch self {
		case .structValue(_):		result = true
		default:			result = false
		}
		return result
	}}

	public func toStruct() -> CNStruct? {
		let result: CNStruct?
		switch self {
		case .structValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public var isArray: Bool { get {
		let result: Bool
		switch self {
		case .arrayValue(_):		result = true
		default:			result = false
		}
		return result
	}}

	public func toArray() -> Array<CNValue>? {
		let result: Array<CNValue>?
		switch self {
		case .arrayValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public var isSet: Bool { get {
		let result: Bool
		switch self {
		case .setValue(_):		result = true
		default:			result = false
		}
		return result
	}}

	public func toSet() -> Array<CNValue>? {
		let result: Array<CNValue>?
		switch self {
		case .setValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public var isObject: Bool { get {
		let result: Bool
		switch self {
		case .objectValue(_):		result = true
		default:			result = false
		}
		return result
	}}

	public func toObject() -> AnyObject? {
		let result: AnyObject?
		switch self {
		case .objectValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public func boolProperty(identifier ident: String) ->  Bool? {
		if let elm = valueProperty(identifier: ident){
			return elm.toBool()
		} else {
			return nil
		}
	}

	public func numberProperty(identifier ident: String) -> NSNumber? {
		if let elm = valueProperty(identifier: ident){
			return elm.toNumber()
		} else {
			return nil
		}
	}

	public func stringProperty(identifier ident: String) -> String? {
		if let elm = valueProperty(identifier: ident){
			return elm.toString()
		} else {
			return nil
		}
	}

	public func dictionaryProperty(identifier ident: String) -> Dictionary<String, CNValue>? {
		if let elm = valueProperty(identifier: ident){
			return elm.toDictionary()
		} else {
			return nil
		}
	}

	public func arrayProperty(identifier ident: String) -> Array<CNValue>? {
		if let elm = valueProperty(identifier: ident){
			return elm.toArray()
		} else {
			return nil
		}
	}

	public func setProperty(identifier ident: String) -> Array<CNValue>? {
		if let elm = valueProperty(identifier: ident){
			return elm.toSet()
		} else {
			return nil
		}
	}

	public func objectProperty(identifier ident: String) -> AnyObject? {
		if let elm = valueProperty(identifier: ident){
			return elm.toObject()
		} else {
			return nil
		}
	}

	public func valueProperty(identifier ident: String) -> CNValue? {
		let result: CNValue?
		switch self {
		case .dictionaryValue(let dict):
			result = dict[ident]
		default:
			result = nil
		}
		return result
	}

	private func propertyCount() -> Int? {
		let result: Int?
		switch self {
		case .dictionaryValue(let dict):
			result = dict.count
		default:
			result = nil
		}
		return result
	}

	private static func stringFromDate(date: Date) -> String {
		let formatter: DateFormatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .gregorian)
		formatter.dateFormat = "yyyy/MM/dd HH:mm:ss Z"
		return formatter.string(from: date)
	}

	private static func dateFromString(string: String) -> Date? {
		let formatter: DateFormatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .gregorian)
		formatter.dateFormat = "yyyy/MM/dd HH:mm:ss Z"
		return formatter.date(from: string)
	}
}
