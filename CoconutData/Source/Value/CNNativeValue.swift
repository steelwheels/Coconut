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

	public func toDate() -> Date? {
		let result: Date?
		switch self {
		case .dateValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public func toRange() -> NSRange? {
		let result: NSRange?
		switch self {
		case .rangeValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public func toPoint() -> CGPoint? {
		let result: CGPoint?
		switch self {
		case .pointValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public func toSize() -> CGSize? {
		let result: CGSize?
		switch self {
		case .sizeValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public func toRect() -> CGRect? {
		let result: CGRect?
		switch self {
		case .rectValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public func toDictionary() -> Dictionary<String, CNNativeValue>? {
		let result: Dictionary<String, CNNativeValue>?
		switch self {
		case .dictionaryValue(let obj):	result = obj
		default:			result = nil
		}
		return result
	}

	public func toArray() -> Array<CNNativeValue>? {
		let result: Array<CNNativeValue>?
		switch self {
		case .arrayValue(let obj):	result = obj
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

	public func dateProperty(identifier ident: String) -> Date? {
		if let elm = valueProperty(identifier: ident){
			return elm.toDate()
		} else {
			return nil
		}
	}

	public func rangeProperty(identifier ident: String) -> NSRange? {
		if let elm = valueProperty(identifier: ident){
			return elm.toRange()
		} else {
			return nil
		}
	}

	public func pointProperty(identifier ident: String) -> CGPoint? {
		if let elm = valueProperty(identifier: ident){
			return elm.toPoint()
		} else {
			return nil
		}
	}

	public func sizeProperty(identifier ident: String) -> CGSize? {
		if let elm = valueProperty(identifier: ident){
			return elm.toSize()
		} else {
			return nil
		}
	}

	public func rectProperty(identifier ident: String) -> CGRect? {
		if let elm = valueProperty(identifier: ident){
			return elm.toRect()
		} else {
			return nil
		}
	}

	public func dictionaryProperty(identifier ident: String) -> Dictionary<String, CNNativeValue>? {
		if let elm = valueProperty(identifier: ident){
			return elm.toDictionary()
		} else {
			return nil
		}
	}

	public func arrayProperty(identifier ident: String) -> Array<CNNativeValue>? {
		if let elm = valueProperty(identifier: ident){
			return elm.toArray()
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

	public func valueProperty(identifier ident: String) -> CNNativeValue? {
		let result: CNNativeValue?
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
			result = CNTextLine(string: "{x:\(val.x), y:\(val.y)}")
		case .sizeValue(let val):
			result = CNTextLine(string: "{width:\(val.width), height:\(val.height)}")
		case .rectValue(let val):
			let ptstr = "origin:{x:\(val.origin.x), y:\(val.origin.y)}"
			let szstr = "size:{width:\(val.size.width), height:\(val.size.height)}"
			result = CNTextLine(string: "{" + ptstr + ", " + szstr + "}")
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
					CNLog(type: .Error, message: "No object", place: #file)
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
			let newdict: Dictionary<String, Any> = [
				"location" : NSNumber(value: Int(val.location)),
				"length"   : NSNumber(value: Int(val.length))
			]
			result = newdict
		case .pointValue(let val):
			let newdict: Dictionary<String, Any> = [
				"x"	: NSNumber(value: Double(val.x)),
				"y"	: NSNumber(value: Double(val.y))
			]
			result = newdict
		case .sizeValue(let val):
			let newdict: Dictionary<String, Any> = [
				"width"	: NSNumber(value: Double(val.width)),
				"height": NSNumber(value: Double(val.height))
			]
			result = newdict
		case .rectValue(let val):
			let origin: Dictionary<String, Any> = [
				"x"	: NSNumber(value: Double(val.origin.x)),
				"y"	: NSNumber(value: Double(val.origin.y))
			]
			let size: Dictionary<String, Any> = [
				"width"	: NSNumber(value: Double(val.size.width)),
				"height": NSNumber(value: Double(val.size.height))
			]
			let rect: Dictionary<String, Any> = [
				"origin": origin,
				"size":	  size
			]
			result = rect
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
			var newdict: Dictionary<String, CNNativeValue> = [:]
			for (key, elm) in val {
				if let child = anyToValue(object: elm) {
					newdict[key] = child
				}
			}
			result = dictionaryToValue(dictionary: newdict)
		} else if let val = obj as? Array<Any> {
			var newarr: Array<CNNativeValue> = []
			for elm in val {
				if let child = anyToValue(object: elm) {
					newarr.append(child)
				}
			}
			result = .arrayValue(newarr)
		} else if let val = obj as? NSObject {
			result = .objectValue(val)
		} else {
			CNLog(type: .Error, message: "Failed to convert \(obj)", place: #file)
			result = nil
		}
		return result
	}

	public static func dictionaryToValue(dictionary dict: Dictionary<String, CNNativeValue>) -> CNNativeValue {
		if dict.count == 2 {
			/* Range type */
			if let locval = dict["location"], let lenval = dict["length"] {
				if let locnum = locval.toNumber(), let lennum = lenval.toNumber() {
					let location = locnum.intValue
					let length   = lennum.intValue
					return .rangeValue(NSRange(location: location, length: length))
				}
			}
			/* Decode point type */
			if let xval = dict["x"], let yval = dict["y"] {
				if let xnum = xval.toNumber(), let ynum = yval.toNumber() {
					let x = CGFloat(xnum.doubleValue)
					let y = CGFloat(ynum.doubleValue)
					return .pointValue(CGPoint(x: x, y:y))
				}
			}
			/* Decode size type */
			if let wval = dict["width"], let hval = dict["height"] {
				if let wnum = wval.toNumber(), let hnum = hval.toNumber() {
					let width  = CGFloat(wnum.doubleValue)
					let height = CGFloat(hnum.doubleValue)
					return .sizeValue(CGSize(width: width, height: height))
				}
			}
			/* Decode rect type */
			if let oval = dict["origin"], let sval = dict["size"] {
				if let origin = oval.toPoint(), let size = sval.toSize() {
					return .rectValue(CGRect(origin: origin, size: size))
				}
			}
		}
		return .dictionaryValue(dict)
	}
}
