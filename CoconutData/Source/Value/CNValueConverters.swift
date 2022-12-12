/*
 * @file	CNValueConverter.swift
 * @brief	Define methods of CNValue class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation



extension CNValue
{
	public static let EnumClassName		= "enum"
	public static let SetClassName		= "set"
	public static let StructClassName	= "struct"

	public static func hasClassName(inValue dict: Dictionary<String, CNValue>, className expname: String) -> Bool {
		if let name = CNValue.className(forValue: dict) {
			return expname == name
		} else {
			return false
		}
	}

	private static func className(forValue dict: Dictionary<String, CNValue>) -> String? {
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

	public func toPrimitiveValue() -> CNValue {
		let result: CNValue
		switch self {
		case .boolValue(_), .numberValue(_), .stringValue(_), .objectValue(_),
		     .dictionaryValue(_), .arrayValue(_):
			result = self
		case .enumValue(let eval):
			let dict: Dictionary<String, CNValue> = [
				"class":	.stringValue(CNValue.EnumClassName),
				"type":		.stringValue(eval.typeName),
				"member":	.stringValue(eval.memberName)
			]
			result = .dictionaryValue(dict)
		case .setValue(let arr):
			let dict: Dictionary<String, CNValue> = [
				"class":	.stringValue(CNValue.SetClassName),
				"values":	.arrayValue(arr)
			]
			result = .dictionaryValue(dict)
		case .structValue(let sval):
			let dict: Dictionary<String, CNValue> = [
				"class":	.stringValue(CNValue.StructClassName),
				"type":		.stringValue(sval.type.typeName),
				"values":	.dictionaryValue(sval.values)
			]
			result = .dictionaryValue(dict)
		}
		return result
	}

	public static func fromPrimiteValue(value src: CNValue) -> CNValue {
		let result: CNValue
		switch src {
		case .boolValue(_), .numberValue(_), .stringValue(_), .objectValue(_),
		     .arrayValue(_), .enumValue(_), .setValue(_), .structValue(_):
			result = src
		case .dictionaryValue(let dict):
			if let clsname = className(forValue: dict) {
				switch clsname {
				case CNValue.EnumClassName:
					if let newval = makeEnumValue(from: dict) {
						result = newval
					} else {
						result = src
					}
				case CNValue.SetClassName:
					if let newval = makeSetValue(from: dict) {
						result = newval
					} else {
						result = src
					}
				case CNValue.StructClassName:
					if let newval = makeStructValue(from: dict) {
						result = newval
					} else {
						result = src
					}
				default:
					result = src
				}
			} else {
				result = src
			}
		}
		let _ = checkValue(value: result)
		return result
	}

	private static func makeEnumValue(from src: Dictionary<String, CNValue>) -> CNValue? {
		if let typeval = src["type"], let membval = src["member"] {
			if let typename = typeval.toString(), let membname = membval.toString() {
				if let etype = CNEnumTable.currentEnumTable().search(byTypeName: typename) {
					if let _ = etype.value(forMember: membname) {
						let eval = CNEnum(type: etype, member: membname)
						return .enumValue(eval)
					}
				}
			}
		}
		CNLog(logLevel: .error, message: "Failed to make enum value", atFunction: #function, inFile: #file)
		return nil
	}

	private static func makeSetValue(from src: Dictionary<String, CNValue>) -> CNValue? {
		if let vals = src["values"] {
			if let srcs = vals.toArray() {
				var newarr: Array<CNValue> = []
				for elm in srcs {
					CNInsertValue(target: &newarr, element: elm)
				}
				return .setValue(newarr)
			}
		}
		CNLog(logLevel: .error, message: "Failed to make set value", atFunction: #function, inFile: #file)
		return nil
	}

	private static func makeStructValue(from src: Dictionary<String, CNValue>) -> CNValue? {
		if let typeval = src["type"], let valuesval = src["values"] {
			if let typename = typeval.toString(), let values = valuesval.toDictionary() {
				if let stype = CNStructTable.currentStructTable().search(byTypeName: typename) {
					return .structValue(CNStruct(type: stype, values: values))
				}
			}
		}
		CNLog(logLevel: .error, message: "Failed to make struct value", atFunction: #function, inFile: #file)
		return nil
	}

	public func toNativeObject() -> AnyObject {
		let result: AnyObject
		switch self {
		case .boolValue(let val):
			result = NSNumber(booleanLiteral: val)
		case .numberValue(let val):
			result = val
		case .stringValue(let val):
			result = val as NSString
		case .enumValue(_):
			let nval = self.toPrimitiveValue()
			result = nval.toNativeObject()
		case .objectValue(let val):
			result = val
		case .dictionaryValue(let dict):
			var newdict: Dictionary<String, AnyObject> = [:]
			for (key, elm) in dict {
				newdict[key] = elm.toNativeObject()
			}
			result = newdict as NSDictionary
		case .structValue(_):
			let nval = self.toPrimitiveValue()
			result = nval.toNativeObject()
		case .arrayValue(let arr):
			var newarr: Array<AnyObject> = []
			for elm in arr {
				newarr.append(elm.toNativeObject())
			}
			result = newarr as NSArray
		case .setValue(_):
			let nval = self.toPrimitiveValue()
			result = nval.toNativeObject()
		}
		return result
	}

	public static func fromNativeObject(from src: AnyObject) -> CNValue {
		let pval = fromNativeObjectToPrimitive(from: src)
		return fromPrimiteValue(value: pval)
	}

	private static func fromNativeObjectToPrimitive(from src: AnyObject) -> CNValue {
		var result: CNValue
		if let num = src as? NSNumber {
			if num.isBoolean {
				result = .boolValue(num.boolValue)
			} else {
				result = .numberValue(num)
			}
		} else if let str = src as? String {
			result = .stringValue(str)
		} else if let arr = src as? Array<AnyObject> {
			var newarr: Array<CNValue> = []
			for elm in arr {
				newarr.append(fromNativeObjectToPrimitive(from: elm))
			}
			result = .arrayValue(newarr)
		} else if let dict = src as? Dictionary<String, AnyObject> {
			var newdict: Dictionary<String, CNValue> = [:]
			for (key, aval) in dict {
				newdict[key] = fromNativeObjectToPrimitive(from: aval)
			}
			result = .dictionaryValue(newdict)
		} else {
			CNLog(logLevel: .error, message: "This is object: \(src)", atFunction: #function, inFile: #file)
			result = .objectValue(src)
		}
		return result
	}

	private static func checkValue(value val: CNValue) -> Bool {
		var result: Bool = true
		switch val {
		case .boolValue(_), .numberValue(_), .stringValue(_), .objectValue(_):
			break /* No check */
		case .enumValue(let eval):
			if let etype = CNEnumTable.currentEnumTable().search(byTypeName: eval.typeName) {
				if etype.value(forMember: eval.memberName) == nil {
					CNLog(logLevel: .error, message: "Unknown struct member name: \(eval.memberName)", atFunction: #function, inFile: #file)
				}
			} else {
				CNLog(logLevel: .error, message: "Unknown enum type name: \(eval.typeName)", atFunction: #function, inFile: #file)
			}
		case .arrayValue(let arr):
			if arr.count >= 2 {
				let firsttype = arr[0].valueType
				for i in 1..<arr.count {
					let resttype = arr[i].valueType
					switch CNValueType.compare(type0: firsttype, type1: resttype) {
					case .orderedSame:
						break // Matched
					case .orderedDescending, .orderedAscending:
						CNLog(logLevel: .error, message: "Unmatched element types in array: arr[0] != arr[\(i)]", atFunction: #function, inFile: #file)
						result = false
					}
				}
			}
		case .setValue(let arr):
			if arr.count >= 2 {
				let firsttype = arr[0].valueType
				for i in 1..<arr.count {
					let resttype = arr[i].valueType
					switch CNValueType.compare(type0: firsttype, type1: resttype) {
					case .orderedSame:
						break // Matched
					case .orderedDescending, .orderedAscending:
						CNLog(logLevel: .error, message: "Unmatched element types in array: arr[0] != arr[\(i)]", atFunction: #function, inFile: #file)
						result = false
					}
				}
			}
		case .dictionaryValue(let dict):
			if let (_, elm) = dict.first {
				let firsttype = elm.valueType
				for (key, restelm) in dict {
					let resttype = restelm.valueType
					switch CNValueType.compare(type0: firsttype, type1: resttype) {
					case .orderedSame:
						break // Matched
					case .orderedDescending, .orderedAscending:
						CNLog(logLevel: .error, message: "Unmatched element types in dictionaruy: value[\(key)]", atFunction: #function, inFile: #file)
						result = false
					}
				}

			}
		case .structValue(let strct):
			if let stype = CNStructTable.currentStructTable().search(byTypeName: strct.type.typeName) {
				for (key, type) in stype.members {
					if let val = strct.value(forMember: key) {
						switch CNValueType.compare(type0: val.valueType, type1: type) {
						case .orderedSame:
							break // Matched
						case .orderedDescending, .orderedAscending:
							CNLog(logLevel: .error, message: "Unmatched member types in dictionaruy: value[\(key)]", atFunction: #function, inFile: #file)
							result = false
						}
					} else {
						CNLog(logLevel: .error, message: "No struct member: \(key)", atFunction: #function, inFile: #file)
					}
				}
			} else {
				CNLog(logLevel: .error, message: "Unknown struct type name: \(strct.type.typeName)", atFunction: #function, inFile: #file)
			}
		}
		return result
	}
}

