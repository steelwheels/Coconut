/*
 * @file	CNNativeValue.swift
 * @brief	Define CNNativeValue class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

/**
 * The data to present JSValue as native data
 */
public enum CNNativeType {
	case	nullType
	case	numberType
	case	stringType
	case	dateType
	case	rangeType
	case	pointType
	case	sizeType
	case	rectType
	case	enumType
	case	dictionaryType
	case	arrayType
	case	URLType
	case	colorType
	case	imageType
	case	objectType

	public func toString() -> String {
		let result: String
		switch self {
		case .nullType:		result = "Null"
		case .numberType:	result = "Number"
		case .stringType:	result = "String"
		case .dateType:		result = "Date"
		case .rangeType:	result = "Range"
		case .pointType:	result = "Point"
		case .sizeType:		result = "Size"
		case .rectType:		result = "Rect"
		case .enumType:		result = "Enum"
		case .dictionaryType:	result = "Dictionary"
		case .arrayType:	result = "Array"
		case .URLType:		result = "URL"
		case .colorType:	result = "Color"
		case .imageType:	result = "Image"
		case .objectType:	result = "Object"
		}
		return result
	}
}

public enum CNNativeValue {
	case nullValue
	case numberValue(_ val: NSNumber)
	case stringValue(_ val: String)
	case dateValue(_ val: Date)
	case rangeValue(_ val: NSRange)
	case pointValue(_ val: CGPoint)
	case sizeValue(_ val: CGSize)
	case rectValue(_ val: CGRect)
	case enumValue(_ type: String, _ val: Int32)	// enum type name and value
	case dictionaryValue(_ val: Dictionary<String, CNNativeValue>)
	case arrayValue(_ val: Array<CNNativeValue>)
	case URLValue(_ val: URL)
	case colorValue(_ val: CNColor)
	case imageValue(_ val: CNImage)
	case objectValue(_ val: NSObject)

	public var valueType: CNNativeType {
		get {
			let result: CNNativeType
			switch self {
			case .nullValue:		result = .nullType
			case .numberValue(_):		result = .numberType
			case .stringValue(_):		result = .stringType
			case .dateValue(_):		result = .dateType
			case .rangeValue(_):		result = .rangeType
			case .pointValue(_):		result = .pointType
			case .sizeValue(_):		result = .sizeType
			case .rectValue(_):		result = .rectType
			case .enumValue(_, _):		result = .enumType
			case .dictionaryValue(_):	result = .dictionaryType
			case .arrayValue(_):		result = .arrayType
			case .URLValue(_):		result = .URLType
			case .colorValue(_):		result = .colorType
			case .imageValue(_):		result = .imageType
			case .objectValue(_):		result = .objectType
			}
			return result
		}
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
		var result: CGPoint? = nil
		switch self {
		case .pointValue(let obj):	result = obj
		case .dictionaryValue(let obj):
			if let xval = obj["x"], let yval = obj["y"] {
				if let xnum = xval.toNumber(), let ynum = yval.toNumber() {
					let xval = CGFloat(xnum.doubleValue)
					let yval = CGFloat(ynum.doubleValue)
					result = CGPoint(x: xval, y:yval)
				}
			}
		default:			result = nil
		}
		return result
	}

	public func toSize() -> CGSize? {
		var result: CGSize? = nil
		switch self {
		case .sizeValue(let obj):	result = obj
		case .dictionaryValue(let obj):
			if let wval = obj["width"], let hval = obj["height"] {
				if let wnum = wval.toNumber(), let hnum = hval.toNumber() {
					let wval = CGFloat(wnum.doubleValue)
					let hval = CGFloat(hnum.doubleValue)
					result = CGSize(width: wval, height: hval)
				}
			}
		default:			result = nil
		}
		return result
	}

	public func toRect() -> CGRect? {
		var result: CGRect? = nil
		switch self {
		case .rectValue(let obj):	result = obj
		case .dictionaryValue:
			if let oval = self.toPoint(), let sval = self.toSize() {
				result = CGRect(origin: oval, size: sval)
			}
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

	public func toURL() -> URL? {
		let result: URL?
		switch self {
		case .URLValue(let url):	result = url
		default:			result = nil
		}
		return result
	}

	public func toColor() -> CNColor? {
		let result: CNColor?
		switch self {
		case .colorValue(let col):	result = col
		default:			result = nil
		}
		return result
	}

	public func toImage() -> CNImage? {
		let result: CNImage?
		switch self {
		case .imageValue(let obj):	result = obj
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

	public func URLProperty(identifier ident: String) -> URL? {
		if let elm = valueProperty(identifier: ident){
			return elm.toURL()
		} else {
			return nil
		}
	}

	public func imageProperty(identifier ident: String) -> CNImage? {
		if let elm = valueProperty(identifier: ident){
			return elm.toImage()
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
		case .enumValue(let type, let val):
			result = CNTextLine(string: ".\(type)(\(val))")
		case .rangeValue(let val):
			result = CNTextLine(string: val.description)
		case .pointValue(let val):
			result = CNTextLine(string: "{x:\(val.x), y:\(val.y)}")
		case .sizeValue(let val):
			result = CNTextLine(string: "{width:\(val.width), height:\(val.height)}")
		case .rectValue(let val):
			let x      = val.origin.x
			let y      = val.origin.y
			let width  = val.size.width
			let height = val.size.height
			result = CNTextLine(string: "{x:\(x), y:\(y), width:\(width), height:\(height)}")
		case .dictionaryValue(let val):
			let sect = CNTextSection()
			sect.header = "{" ; sect.footer = "}"
			let keys = val.keys.sorted()
			for key in keys {
				if let elm = val[key] {
					let elmtxt = elm.toText()
					if let sectxt = elmtxt as? CNTextSection {
						sectxt.header = key + ": " + sectxt.header
					} else {
						elmtxt.prepend(string: key + ": ")
					}
					sect.add(text: elmtxt)
				} else {
					CNLog(logLevel: .error, message: "No object for key: \(key)", atFunction: #function, inFile: #file)
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
		case .URLValue(let val):
			result = CNTextLine(string: "\(val.absoluteString)")
		case .colorValue(let val):
			result = CNTextLine(string: "\(val.description)")
		case .imageValue(let val):
			#if os(OSX)
				let name: String
				if let n = val.name() {
					name = n
				} else {
					name = "<unknown>"
				}
				let size = val.size
				result = CNTextLine(string: "{image: name:\(name), size:\(size.width) x \(size.height)}")
			#else
				let size = val.size
				result = CNTextLine(string: "{image: size:\(size.width) x \(size.height)}")
			#endif
		case .objectValue(let val):
			let classname = String(describing: type(of: val))
			result = CNTextLine(string: "object(\(classname))")
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
		case .enumValue(_, let val):
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
			let rect: Dictionary<String, Any> = [
				"x"	: NSNumber(value: Double(val.origin.x)),
				"y"	: NSNumber(value: Double(val.origin.y)),
				"width"	: NSNumber(value: Double(val.size.width)),
				"height": NSNumber(value: Double(val.size.height))
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
		case .URLValue(let val):
			result = val
		case .colorValue(let val):
			let (red, green, blue, alpha) = val.toRGBA()
			let col: Dictionary<String, Any> = [
				"red"	: NSNumber(floatLiteral: Double(red  )),
				"green"	: NSNumber(floatLiteral: Double(green)),
				"blue"	: NSNumber(floatLiteral: Double(blue )),
				"alpha" : NSNumber(floatLiteral: Double(alpha))
			]
			result = col
		case .imageValue(let val):
			result = val
		case .objectValue(let val):
			result = val
		}
		return result
	}

	public static func anyToValue(object obj: Any) -> CNNativeValue? {
		var result: CNNativeValue? = nil
		if let _ = obj as? NSNull {
			result = .nullValue
		} else if let val = obj as? NSNumber {
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
		} else if let val = obj as? URL {
			result = .URLValue(val)
		} else if let val = obj as? CNColor {
			result = .colorValue(val)
		} else if let val = obj as? CNImage {
			result = .imageValue(val)
		} else if let val = obj as? NSObject {
			result = .objectValue(val)
		} else {
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
		} else if dict.count == 4 {
			/* Decode rect type */
			if let xval = dict["x"], let yval = dict["y"], let wval = dict["width"], let hval = dict["height"] {
				if let x = xval.toNumber(), let y = yval.toNumber(), let width = wval.toNumber(), let height = hval.toNumber() {
					return .rectValue(CGRect(x: x.doubleValue, y: y.doubleValue, width: width.doubleValue, height: height.doubleValue))
				}
			}
			/* Decode color type */
			if let rval = dict["red"], let gval = dict["green"], let bval = dict["blue"], let aval = dict["alpha"] {
				if let rednum = rval.toNumber(), let greennum = gval.toNumber(), let bluenum = bval.toNumber(), let alphanum = aval.toNumber() {
					let red   = CGFloat(rednum.floatValue)
					let green = CGFloat(greennum.floatValue)
					let blue  = CGFloat(bluenum.floatValue)
					let alpha = CGFloat(alphanum.floatValue)
					let color = CNColor(red: red, green: green, blue: blue, alpha: alpha)
					return  .colorValue(color)
				}
			}
		}
		return .dictionaryValue(dict)
	}
}
