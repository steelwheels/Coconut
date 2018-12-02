/*
 * @file	CNNativeValue.swift
 * @brief	Define CNNativeValue class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

/**
 * The data to present JSValue as native data
 */
public enum CNNativeValue {
	case nullValue
	case numberValue(_ val: NSNumber)
	case stringValue(_ val: String)
	case dateValue(_ val: Date)
	case rangeValue(_ val: NSRange)
	case pointValue(_ val: CGPoint)
	case sizeValue(_ val: CGSize)
	case rectValue(_ val: CGRect)
	case dictionaryValue(_ val: Dictionary<String, CNNativeValue>)
	case arrayValue(_ val: Array<CNNativeValue>)
	case objectValue(_ val: NSObject)

	public func numberElement(identifier ident: String) -> NSNumber? {
		if let elm = valueElement(identifier: ident){
			switch elm {
			case .numberValue(let obj):
				return obj
			default:
				break // do not return anything
			}
		}
		return nil
	}

	public func stringElement(identifier ident: String) -> String? {
		if let elm = valueElement(identifier: ident){
			switch elm {
			case .stringValue(let obj):
				return obj
			default:
				break // do not return anything
			}
		}
		return nil
	}

	public func pointElement(identifier ident: String) -> CGPoint? {
		if let elm = valueElement(identifier: ident){
			switch elm {
			case .pointValue(let obj):
				return obj
			default:
				break // do not return anything
			}
		}
		return nil
	}

	public func dictionaryElement(identifier ident: String) -> Dictionary<String, CNNativeValue>? {
		if let elm = valueElement(identifier: ident){
			switch elm {
			case .dictionaryValue(let obj):
				return obj
			default:
				break // do not return anything
			}
		}
		return nil
	}

	private func valueElement(identifier ident: String) -> CNNativeValue? {
		let result: CNNativeValue?
		switch self {
		case .dictionaryValue(let dict):
			result = dict[ident]
		default:
			result = nil
		}
		return result
	}

	public func toText() -> CNText {
		let result: CNText
		switch self {
		case .nullValue:
			result = CNTextLine(string: "null")
		case .numberValue(let val):
			result = CNTextLine(string: val.description)
		case .stringValue(let val):
			result = CNTextLine(string: "\"\(val)\"")
		case .dateValue(let val):
			result = CNTextLine(string: val.description)
		case .rangeValue(let val):
			result = CNTextLine(string: val.description)
		case .pointValue(let val):
			result = CNTextLine(string: "(x:\(val.x), y:\(val.y))")
		case .sizeValue(let val):
			result = CNTextLine(string: "(w:\(val.width), h:\(val.height))")
		case .rectValue(let val):
			let ptstr = "(x:\(val.origin.x), y:\(val.origin.y))"
			let szstr = "(w:\(val.size.width), h:\(val.size.height))"
			result = CNTextLine(string: "(" + ptstr + ", " + szstr + ")")
		case .dictionaryValue(let val):
			let sect = CNTextSection()
			sect.header = "{" ; sect.footer = "}"
			let keys = val.keys.sorted()
			for key in keys {
				if let elm = val[key] {
					let elmtxt = elm.toText()
					if let elmline = elmtxt as? CNTextLine {
						elmline.prepend(string: key + ": ")
						sect.add(text: elmline)
					} else {
						sect.add(string: key + ": ")
						sect.add(text: elmtxt)
					}
				} else {
					NSLog("No object at \(#function)")
					sect.add(text: CNTextLine(string: "?"))
				}
			}
			result = sect
		case .arrayValue(let val):
			let sect = CNTextSection()
			sect.header = "[" ; sect.footer = "]"
			for elm in val {
				let elmtxt = elm.toText()
				sect.add(text: elmtxt)
			}
			result = sect
		case .objectValue(let val):
			result = CNTextLine(string: "\(val.description)")
		}
		return result
	}

	public func toAny() -> Any {
		let result: Any
		switch self {
		case .nullValue:
			result = NSNull()
		case .numberValue(let val):
			result = val
		case .stringValue(let val):
			result = val
		case .dateValue(let val):
			result = val
		case .rangeValue(let val):
			result = val
		case .pointValue(let val):
			result = val
		case .sizeValue(let size):
			result = size
		case .rectValue(let size):
			result = size
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
		case .objectValue(let val):
			result = val
		}
		return result
	}

	public static func anyToValue(object obj: Any) -> CNNativeValue? {
		var result: CNNativeValue? = nil
		if let val = obj as? NSNumber {
			result = .numberValue(val)
		} else if let val = obj as? String {
			result = .stringValue(val)
		} else if let val = obj as? Date {
			result = .dateValue(val)
		} else if let val = obj as? NSRange {
			result = .rangeValue(val)
		} else if let val = obj as? CGPoint {
			result = .pointValue(val)
		} else if let val = obj as? CGSize {
			result = .sizeValue(val)
		} else if let val = obj as? CGRect {
			result = .rectValue(val)
		} else if let val = obj as? Dictionary<String, Any> {
			result = dictionaryToValue(dictionary: val)
		} else if let val = obj as? Array<Any> {
			result = arrayToValue(array: val)
		} else if let val = obj as? NSObject {
			result = .objectValue(val)
		} else {
			result = nil
		}
		return result
	}

	private static func dictionaryToValue(dictionary value: Dictionary<String, Any> ) -> CNNativeValue? {
		var result: Dictionary<String, CNNativeValue> = [:]
		for (key, elm) in value {
			if let child = anyToValue(object: elm) {
				result[key] = child
			} else {
				NSLog("Invalid object at \(#function)")
			}
		}
		return .dictionaryValue(result)
	}

	private static func arrayToValue(array value: Array<Any>) -> CNNativeValue? {
		var result: Array<CNNativeValue> = []
		for elm in value {
			if let child = anyToValue(object: elm) {
				result.append(child)
			} else {
				NSLog("Invalid object at \(#function)")
			}
		}
		return .arrayValue(result)
	}
}
