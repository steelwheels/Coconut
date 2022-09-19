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

/**
 * The data to present JSValue as native data
 */
public enum CNValueType
{
	case	boolType
	case	numberType
	case	stringType
	case	enumType(String)	// enum-type name
	case	dictionaryType
	case	arrayType
	case	setType
	case	objectType

	public var description: String { get {
		let result: String
		switch self {
		case .boolType:			result = "Bool"
		case .numberType:		result = "Number"
		case .stringType:		result = "String"
		case .enumType(let etype):	result = "Enum(\(etype))"
		case .dictionaryType:		result = "Dictionary"
		case .arrayType:		result = "Array"
		case .setType:			result = "Set"
		case .objectType:		result = "Object"
		}
		return result
	}}

	public static func decode(string str: String) -> CNValueType? {
		let (typename, paramp) = CNValueType.decodeType(string: str)

		let result: CNValueType?
		switch typename {
		case "Bool":		result = .boolType
		case "Number":		result = .numberType
		case "String":		result = .stringType
		case "Enum":
			if let param = paramp {
				result = .enumType(param)
			} else {
				result = nil
			}
		case "Dictionary":	result = .dictionaryType
		case "Array":		result = .arrayType
		case "Set":		result = .setType
		case "Object":		result = .objectType
		default:		result = nil
		}
		return result
	}

	private static func decodeType(string str: String) -> (String, String?) { // (type-name, parameter)
		let substrs1 = str.split(separator: "(")
		if substrs1.count >= 2 {
			let substrs2 = substrs1[1].split(separator: ")")
			if substrs2.count >= 2 {
				return (String(substrs1[0]), String(substrs2[0]))
			}
		}
		return (str, nil)
	}

	public func compare(_ dst: CNValueType) -> ComparisonResult {
		let srcdesc = self.description
		let dstdesc = dst.description
		if srcdesc > dstdesc {
			return .orderedDescending
		} else if srcdesc < dstdesc {
			return .orderedAscending
		} else {
			return .orderedSame
		}
	}
}

public enum CNValue {
	case boolValue(_ val: Bool)
	case numberValue(_ val: NSNumber)
	case stringValue(_ val: String)
	case enumValue(_ val: CNEnum)
	case dictionaryValue(_ val: Dictionary<String, CNValue>)
	case arrayValue(_ val: Array<CNValue>)
	case setValue(_ val: Array<CNValue>)	// Sorted in ascending order
	case objectValue(_ val: NSObject?)	// will be null

	public var valueType: CNValueType {
		get {
			let result: CNValueType
			switch self {
			case .boolValue(_):		result = .boolType
			case .numberValue(_):		result = .numberType
			case .stringValue(_):		result = .stringType
			case .enumValue(let eobj):	result = .enumType(eobj.typeName)
			case .dictionaryValue(_):	result = .dictionaryType
			case .arrayValue(_):		result = .arrayType
			case .setValue(_):		result = .setType
			case .objectValue(_):		result = .objectType
			}
			return result
		}
	}

	public static var null: CNValue { get {
		return CNValue.objectValue(nil)
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

	public func toObject() -> NSObject? {
		let result: NSObject?
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

	public func objectProperty(identifier ident: String) -> NSObject? {
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
			result = line
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
			var line  = "["
			var is1st = true
			for elm in val {
				if is1st { is1st = false } else { line += ", " }
				line += elm.description
			}
			line += "]"
			result = line
		case .objectValue(let val):
			let classname = String(describing: type(of: val))
			result = "instanceOf(\(classname))"
		}
		return result
	}}

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

	public func toAny() -> Any {
		let result: Any
		switch self {
		case .boolValue(let val):
			result = val
		case .numberValue(let val):
			result = val
		case .stringValue(let val):
			result = val
		case .enumValue(let val):
			result = val.toValue()
		case .objectValue(let val):
			if let v = val {
				result = v
			} else {
				result = NSNull()
			}
		case .dictionaryValue(let dict):
			var newdict: Dictionary<String, Any> = [:]
			for (key, elm) in dict {
				newdict[key] = elm.toAny()
			}
			result = newdict
		case .arrayValue(let arr):
			var newarr: Array<Any> = []
			for elm in arr {
				newarr.append(elm.toAny())
			}
			result = newarr
		case .setValue(let arr):
			var newarr: Array<Any> = []
			for elm in arr {
				newarr.append(elm.toAny())
			}
			result = newarr
		}
		return result
	}

	public static func anyToValue(object obj: Any) -> CNValue? {
		var result: CNValue? = nil
		if let _ = obj as? NSNull {
			result = .objectValue(nil)
		} else if let val = obj as? NSNumber {
			result = .numberValue(val)
		} else if let val = obj as? String {
			result = .stringValue(val)
		} else if let val = obj as? Dictionary<String, Any> {
			var newdict: Dictionary<String, CNValue> = [:]
			for (key, elm) in val {
				if let child = anyToValue(object: elm) {
					newdict[key] = child
				}
			}
			if let val = dictionaryToValue(dictionary: newdict){
				result = val
			} else {
				result = .dictionaryValue(newdict)
			}
		} else if let val = obj as? Array<Any> {
			var newarr: Array<CNValue> = []
			for elm in val {
				if let child = anyToValue(object: elm) {
					newarr.append(child)
				}
			}
			result = .arrayValue(newarr)
		} else if let val = obj as? NSObject {
			// this must be put at the last
			result = .objectValue(val)
		} else {
			result = nil
		}
		return result
	}

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
}
