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
	case arrayValue(_ val: Array<CNValue>)
	case setValue(_ val: Array<CNValue>)	// Sorted in ascending order
	case interfaceValue(_ val: CNInterfaceValue)
	case objectValue(_ val: AnyObject)

	public var valueType: CNValueType { get {
		let result: CNValueType
		switch self {
		case .boolValue(_):		result = .boolType
		case .numberValue(_):		result = .numberType
		case .stringValue(_):		result = .stringType
		case .dictionaryValue(_):	result = .dictionaryType(.anyType)
		case .arrayValue(_):		result = .arrayType(.anyType)
		case .setValue(_):		result = .setType(.anyType)
		case .interfaceValue(let val):	result = .interfaceType(val.type)
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

	public func toBool() -> Bool? {
		let result: Bool?
		switch self {
		case .boolValue(let val):	result = val
		default:			result = nil
		}
		return result
	}

	public func toNumber() -> NSNumber? {
		let result: NSNumber?
		switch self {
		case .numberValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public func toString() -> String? {
		let result: String?
		switch self {
		case .stringValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public func toEnum() -> CNEnum? {
		let result: CNEnum?
		switch self {
		case .enumValue(let eval):		result = eval
		case .dictionaryValue(let dict):	result = CNEnum.fromValue(value: dict)
		default:				result = nil
		}
		return result
	}

	public func toDictionary() -> Dictionary<String, CNValue>? {
		let result: Dictionary<String, CNValue>?
		switch self {
		case .dictionaryValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public func toInterface(interfaceName ifname: String) -> CNInterfaceValue? {
		let result: CNInterfaceValue?
		switch self {
		case .interfaceValue(let ifval):
			if ifval.type.name == ifname {
				result = ifval
			} else {
				result = nil
			}
		default:				result = nil
		}
		return result
	}

	public func toArray() -> Array<CNValue>? {
		let result: Array<CNValue>?
		switch self {
		case .arrayValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public func toSet() -> Array<CNValue>? {
		let result: Array<CNValue>?
		switch self {
		case .setValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

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

	public var description: String { get {
		let result: String
		switch self {
		case .boolValue(let val):
			result = val ? "true" : "false"
		case .numberValue(let val):
			result = val.stringValue
		case .stringValue(let val):
			result = val
		case .enumValue(let val):
			result = val.memberName
		case .dictionaryValue(let val):
			result = dictionaryToDescription(dictionary: val)
		case .arrayValue(let val):
			var line  = "["
			var is1st = true
			for elm in val {
				if is1st { is1st = false } else { line += ", " }
				line += elm.description
			}
			line += "]"
			result = line
		case .setValue(let val):
			result = val.description
		case .interfaceValue(let val):
			result = val.type.name + ":" + dictionaryToDescription(dictionary: val.values)
		case .objectValue(let val):
			let classname = String(describing: type(of: val))
			result = "instanceOf(\(classname))"
		}
		return result
	}}

	private func dictionaryToDescription(dictionary val: Dictionary<String, CNValue>) -> String {
		var line  = "["
		var is1st = true
		let keys  = val.keys.sorted()
		for key in keys {
			if is1st { is1st = false } else { line += ", " }
			if let elm = val[key] {
				line += key + ":" + elm.description
			} else {
				CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
			}
		}
		line += "]"
		return line
	}

	public func toScript() -> CNText {
		let result: CNText
		switch self {
		case .boolValue(_), .numberValue(_), .objectValue(_):
			// Use description
			result = CNTextLine(string: self.description)
		case .stringValue(let val):
			let txt = CNStringUtil.insertEscapeForQuote(source: val)
			result = CNTextLine(string: "\"" + txt + "\"")
		case .enumValue(let val):
			let txt = "\(val.typeName).\(val.memberName)"
			result = CNTextLine(string: txt)
		case .dictionaryValue(let val):
			result = dictionaryToScript(dictionary: val)
		case .arrayValue(let val):
			result = arrayToScript(array: val)
		case .setValue(let val):
			result = setToScript(set: val)
		case .interfaceValue(let val):
			result = interfaceToScript(value: val)
		}
		return result
	}

	private func arrayToScript(array arr: Array<CNValue>) -> CNTextSection {
		let sect = CNTextSection()
		sect.header = "[" ; sect.footer = "]" ; sect.separator = ","
		for elm in arr {
			sect.add(text: elm.toScript())
		}
		return sect
	}

	private func setToScript(set vals: Array<CNValue>) -> CNTextSection {
		let dict: Dictionary<String, CNValue> = [
			"class":	.stringValue(CNValueSet.ClassName),
			"values":	.arrayValue(vals)
		]
		return dictionaryToScript(dictionary: dict)
	}

	private func dictionaryToScript(dictionary dict: Dictionary<String, CNValue>) -> CNTextSection {
		let sect = CNTextSection()
		sect.header = "{" ; sect.footer = "}" ; sect.separator = ","
		let keys = dict.keys.sorted()
		for key in keys {
			if let val = dict[key] {
				let newtxt = val.toScript()
				let labtxt = CNLabeledText(label: "\(key): ", text: newtxt)
				sect.add(text: labtxt)
			}
		}
		return sect
	}

	private func interfaceToScript(value val: CNInterfaceValue) -> CNTextSection {
		return dictionaryToScript(dictionary: val.values)
	}

	public static func className(forValue dict: Dictionary<String, CNValue>) -> String? {
		guard let val = dict["class"] else {
			return nil
		}
		switch val {
		case .stringValue(let str):
			return str
		default:
			return nil
		}
	}

	public static func hasClassName(inValue dict: Dictionary<String, CNValue>, className expname: String) -> Bool {
		if let name = CNValue.className(forValue: dict) {
			return expname == name
		} else {
			return false
		}
	}

	public static func setClassName(toValue dict: inout Dictionary<String, CNValue>, className name: String){
		dict["class"] = .stringValue(name)
	}

	public static func removeClassName(fromValue dict: inout Dictionary<String, CNValue>){
		dict["class"] = nil
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
