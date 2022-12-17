/*
 * @file	CNPrimitiveValue.swift
 * @brief	Define CNPrimitiveValue class
 * @par Copyright
 *   Copyright (C) 2033 Steel Wheels Project
 */

import Foundation

public enum CNPrimitiveValue
{
	static let PrimitiveProperty: String 	= "primitive"
	private enum PrimitiveValue: String {
		case dictionaryValue	= "dictionary"
		case setValue		= "set"
		case enumValue		= "enum"
	}

	case boolValue(_ val: Bool)
	case numberValue(_ val: NSNumber)
	case stringValue(_ val: String)
	case dictionaryValue(_ val: Dictionary<String, CNPrimitiveValue>)
	case arrayValue(_ val: Array<CNPrimitiveValue>)
	case objectValue(_ val: AnyObject)

	public static func fromValue(_ src: CNValue) -> CNPrimitiveValue {
		let result: CNPrimitiveValue
		switch src {
		case .boolValue(let val):
			result = .boolValue(val)
		case .numberValue(let val):
			result = .numberValue(val)
		case .stringValue(let val):
			result = .stringValue(val)
		case .dictionaryValue(let val):
			result = fromDictionaryValue(val)
		case .arrayValue(let val):
			result = fromArrayValue(val)
		case .setValue(let val):
			result = fromSetValue(val)
		case .enumValue(let val):
			result = fromEnumValue(val)
		case .objectValue(let val):
			result = .objectValue(val)
		}
		return result
	}

	public func toValue() -> CNValue {
		let result: CNValue
		switch self {
		case .boolValue(let val):
			result = .boolValue(val)
		case .numberValue(let val):
			result = .numberValue(val)
		case .stringValue(let val):
			result = .stringValue(val)
		case .arrayValue(let val):
			result = CNPrimitiveValue.toArrayValue(val)
		case .dictionaryValue(let val):
			result = CNPrimitiveValue.toDictionaryValue(val)
		case .objectValue(let obj):
			result = .objectValue(obj)
		}
		return result
	}

	private static func fromDictionaryValue(_ src: Dictionary<String, CNValue>) -> CNPrimitiveValue {
		let result: Dictionary<String, CNValue> = [
			PrimitiveProperty : .stringValue(PrimitiveValue.dictionaryValue.rawValue),
			"values" :	    .dictionaryValue(src)
		]
		return fromAnyDictionaryValue(result)
	}

	private static func toDictionaryValue(_ src: Dictionary<String, CNPrimitiveValue>) -> CNValue {
		if let primval = stringProperty(for: PrimitiveProperty, in: src) {
			switch PrimitiveValue(rawValue: primval) {
			case .dictionaryValue:
				if let dval = src["values"] {
					switch dval {
					case .dictionaryValue(let dict):
						return toNormalDictionaryValue(dict)
					default:
						break
					}
				}
			case .setValue:
				if let setval = toSetValue(src) {
					return setval
				}
			case .enumValue:
				if let setval = toEnumValue(src) {
					return setval
				}
			case .none:
				CNLog(logLevel: .error, message: "Unknown primitive type: \(primval)", atFunction: #function, inFile: #file)
			}
		} else {
			CNLog(logLevel: .error, message: "Property \"\(PrimitiveProperty)\" is not found", atFunction: #function, inFile: #file)
		}
		return toNormalDictionaryValue(src)
	}

	private static func toNormalDictionaryValue(_ src: Dictionary<String, CNPrimitiveValue>) -> CNValue {
		var result: Dictionary<String, CNValue> = [:]
		for (name, srcval) in src {
			result[name] = srcval.toValue()
		}
		return .dictionaryValue(result)
	}

	private static func fromArrayValue(_ src: Array<CNValue>) -> CNPrimitiveValue {
		let result = src.map{ CNPrimitiveValue.fromValue($0) }
		return .arrayValue(result)
	}

	public static func toArrayValue(_ src: Array<CNPrimitiveValue>) -> CNValue {
		let result = src.map{ $0.toValue() }
		return .arrayValue(result)
	}

	private static func fromSetValue(_ src: Array<CNValue>) -> CNPrimitiveValue {
		let result: Dictionary<String, CNValue> = [
			PrimitiveProperty : .stringValue(PrimitiveValue.setValue.rawValue),
			"values" :	    .arrayValue(src)
		]
		return fromAnyDictionaryValue(result)
	}

	private static func toSetValue(_ src: Dictionary<String, CNPrimitiveValue>) -> CNValue? {
		if let vals = src["values"] {
			switch vals {
			case .arrayValue(let arr):
				let newarr = arr.map{ $0.toValue() }
				return .arrayValue(newarr)
			default:
				break
			}
		}
		CNLog(logLevel: .error, message: "Failed to allocate set value", atFunction: #function, inFile: #file)
		return nil
	}

	private static func fromEnumValue(_ src: CNEnum) -> CNPrimitiveValue {
		let typename: String
		if let etype = src.enumType {
			typename = etype.typeName
		} else {
			typename = "none"
		}
		let result: Dictionary<String, CNValue> = [
			PrimitiveProperty : .stringValue(PrimitiveValue.enumValue.rawValue),
			"typeName"	  : .stringValue(typename),
			"memberName"	  : .stringValue(src.memberName)
		]
		return fromAnyDictionaryValue(result)
	}

	private static func toEnumValue(_ src: Dictionary<String, CNPrimitiveValue>) -> CNValue? {
		if let typename = stringProperty(for: "typeName", in: src),
		   let membname = stringProperty(for: "memberName", in: src) {
			if let etype = CNEnumTable.currentEnumTable().search(byTypeName: typename) {
				return .enumValue(CNEnum(type: etype, member: membname))
			}
		}
		CNLog(logLevel: .error, message: "Failed to allocate enum value", atFunction: #function, inFile: #file)
		return nil
	}

	private static func fromAnyDictionaryValue(_ src: Dictionary<String, CNValue>) -> CNPrimitiveValue {
		var result: Dictionary<String, CNPrimitiveValue> = [:]
		for (name, sval) in src {
			switch sval {
			case .dictionaryValue(let dict):
				result[name] = fromAnyDictionaryValue(dict)
			default:
				result[name] = CNPrimitiveValue.fromValue(sval)
			}
		}
		return .dictionaryValue(result)
	}

	private static func stringProperty(for name: String, in src: Dictionary<String, CNPrimitiveValue>) -> String? {
		if let propval = src[name] {
			switch propval {
			case .stringValue(let str):
				return str
			default:
				break
			}
		}
		return nil
	}

	public func toObject() -> AnyObject {
		let result: AnyObject
		switch self {
		case .boolValue(let val):
			result = NSNumber(booleanLiteral: val)
		case .numberValue(let val):
			result = val
		case .stringValue(let val):
			result = val as NSString
		case .arrayValue(let arr):
			let newarr = arr.map{ $0.toObject }
			result = newarr as NSArray
		case .dictionaryValue(let dict):
			var newdict: Dictionary<NSString, AnyObject> = [:]
			for (name, val) in dict {
				newdict[name as NSString] = val.toObject()
			}
			result = newdict as NSDictionary
		case .objectValue(let val):
			result = val
		}
		return result
	}

	public static func fromObject(_ src: AnyObject) -> CNPrimitiveValue {
		let result: CNPrimitiveValue
		if let num = src as? NSNumber {
			if num.hasBoolValue {
				result = .boolValue(num.boolValue)
			} else {
				result = .numberValue(num)
			}
		} else if let str = src as? NSString {
			result = .stringValue(str as String)
		} else if let arr = src as? Array<AnyObject> {
			let newarr = arr.map{ fromObject($0) }
			result = .arrayValue(newarr)
		} else if let dict = src as? Dictionary<String, AnyObject> {
			var newdict: Dictionary<String, CNPrimitiveValue> = [:]
			for (name, val) in dict {
				newdict[name] = fromObject(val)
			}
			result = .dictionaryValue(newdict)
		} else {
			CNLog(logLevel: .error, message: "Object \(src) is converted to value", atFunction: #function, inFile: #file)
			result = .objectValue(src)
		}
		return result
	}

}

