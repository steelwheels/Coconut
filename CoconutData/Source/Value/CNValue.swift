/*
 * @file	CNValue.swift
 * @brief	Define CNValue class
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
public enum CNValueType: Int
{
	case	nullType
	case	boolType
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

	public var description: String { get {
		let result: String
		switch self {
		case .nullType:		result = "Null"
		case .boolType:		result = "Bool"
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
	}}

	public func compare(_ dst: CNValueType) -> ComparisonResult {
		let srcv = self.rawValue
		let dstv = dst.rawValue
		if srcv > dstv {
			return .orderedDescending
		} else if srcv == dstv {
			return .orderedSame
		} else {
			return .orderedAscending
		}
	}

	public static func isScaler(type typ: CNValueType) -> Bool {
		let result: Bool
		switch typ {
		case .nullType, .boolType, .numberType, .stringType, .dateType, .URLType, .imageType, .objectType:
			result = true
		case .rangeType, .pointType, .sizeType, .rectType, .enumType, .dictionaryType, .arrayType, .colorType:
			result = false
		}
		return result
	}
}

public enum CNValue {
	case nullValue
	case boolValue(_ val: Bool)
	case numberValue(_ val: NSNumber)
	case stringValue(_ val: String)
	case dateValue(_ val: Date)
	case rangeValue(_ val: NSRange)
	case pointValue(_ val: CGPoint)
	case sizeValue(_ val: CGSize)
	case rectValue(_ val: CGRect)
	case enumValue(_ type: String, _ val: Int32)	// enum type name and value
	case dictionaryValue(_ val: Dictionary<String, CNValue>)
	case arrayValue(_ val: Array<CNValue>)
	case URLValue(_ val: URL)
	case colorValue(_ val: CNColor)
	case imageValue(_ val: CNImage)
	case objectValue(_ val: NSObject)

	public var valueType: CNValueType {
		get {
			let result: CNValueType
			switch self {
			case .nullValue:		result = .nullType
			case .boolValue(_):		result = .boolType
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

	public func toEnum() -> (String, Int32)? {
		let result: (String, Int32)?
		switch self {
		case .enumValue(let typestr, let val):
			result = (typestr, val)
		default:
			result = nil
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

	public func isEmpty() -> Bool {
		let result: Bool
		switch self {
		case .nullValue:
			result = true
		case .boolValue(_), .numberValue(_), .dateValue(_), .rangeValue(_), .pointValue(_),
		     .sizeValue(_), .rectValue(_), .enumValue(_, _), .URLValue(_), .colorValue(_),
		     .imageValue(_), .objectValue(_):
			result = false
		case .stringValue(let str):
			result = str.isEmpty
		case .dictionaryValue(let dict):
			result = dict.count == 0
		case .arrayValue(let arr):
			result = arr.count == 0
		}
		return result
	}

	public func toText() -> CNText {
		let result: CNText
		switch self {
		case .nullValue:
			result = CNTextLine(string: "null")
		case .boolValue(let val):
			result = CNTextLine(string: "\(val)")
		case .numberValue(let val):
			result = CNTextLine(string: val.stringValue)
		case .stringValue(let val):
			result = CNTextLine(string: "\"" + val + "\"")
		case .dateValue(let val):
			result = CNTextLine(string: "\"" + CNValue.stringFromDate(date: val) + "\"")
		case .enumValue(let type, let val):
			result = CNTextLine(string: ".\(type)(\(val))")
		case .rangeValue(let val):
			result = CNTextLine(string: "\"" + val.description + "\"")
		case .pointValue(let val):
			result = dictionaryToText(dictionary: val.toValue())
		case .sizeValue(let val):
			result = dictionaryToText(dictionary: val.toValue())
		case .rectValue(let val):
			result = dictionaryToText(dictionary: val.toValue())
		case .dictionaryValue(let val):
			result = dictionaryToText(dictionary: val)
		case .arrayValue(let val):
			result = arrayToText(array: val)
		case .URLValue(let val):
			result = CNTextLine(string: "\"" + val.path + "\"")
		case .colorValue(let val):
			result = CNTextLine(string: "\"\(val.description)\"")
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

	private func arrayToText(array arr: Array<CNValue>) -> CNTextSection {
		let sect = CNTextSection()
		sect.header = "[" ; sect.footer = "]" ; sect.separator = ","
		for elm in arr {
			sect.add(text: elm.toText())
		}
		return sect
	}

	private func dictionaryToText(dictionary dict: Dictionary<String, CNValue>) -> CNTextSection {
		let sect = CNTextSection()
		sect.header = "{" ; sect.footer = "}" ; sect.separator = ","
		let keys = dict.keys.sorted()
		for key in keys {
			if let val = dict[key] {
				let newtxt = val.toText()
				let labtxt = CNLabeledText(label: "\(key): ", text: newtxt)
				sect.add(text: labtxt)
			}
		}
		return sect
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
		case .nullValue:
			result = NSNull()
		case .boolValue(let val):
			result = val
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

	public static func anyToValue(object obj: Any) -> CNValue? {
		var result: CNValue? = nil
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
			var newdict: Dictionary<String, CNValue> = [:]
			for (key, elm) in val {
				if let child = anyToValue(object: elm) {
					newdict[key] = child
				}
			}
			result = dictionaryToValue(dictionary: newdict)
		} else if let val = obj as? Array<Any> {
			var newarr: Array<CNValue> = []
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

	public static func stringToValue(type typ: CNValueType, source src: String) -> CNValue? {
		var result: CNValue? = nil
		switch typ {
		case .nullType:
			result = .nullValue
		case .boolType:
			switch src.caseInsensitiveCompare("true") {
			case .orderedSame:
				result = .boolValue(true)
			case .orderedDescending, .orderedAscending:
				result = .boolValue(false)
			}
		case .numberType:
			if let dblval = Double(src) {
				if dblval.truncatingRemainder(dividingBy: 1) == 0.0 {
					result = .numberValue(NSNumber(value: Int(dblval)))
				} else {
					result = .numberValue(NSNumber(value: dblval))
				}
			}
		case .stringType:
			result = .stringValue(src)
		case .dateType:
			if let date = dateFromString(string: src) {
				result = .dateValue(date)
			}
		case .URLType:
			let url = URL(fileURLWithPath: src)
			result = .URLValue(url)
		case .rangeType, .pointType, .sizeType, .rectType, .enumType, .dictionaryType, .arrayType,
		     .colorType, .imageType, .objectType:
			CNLog(logLevel: .error, message: "Not supported", atFunction: #function, inFile: #file)
		}
		return result
	}

	public static func valueToDictionary(value val: CNValue) -> Dictionary<String, CNValue>? {
		var result: Dictionary<String, CNValue>? = nil
		switch val {
		case .nullValue, .boolValue(_), .numberValue(_), .stringValue(_), .dateValue(_),
		     .arrayValue(_), .URLValue(_), .imageValue(_), .objectValue(_):
			break
		case .rangeValue(let src):
			let dict: Dictionary<String, CNValue> = [
				"location":	.numberValue(NSNumber(value: src.location)),
				"length":	.numberValue(NSNumber(value: src.length))
			]
			result = dict
		case .pointValue(let src):
			let dict: Dictionary<String, CNValue> = [
				"x":		.numberValue(NSNumber(value: Double(src.x))),
				"y":		.numberValue(NSNumber(value: Double(src.y)))
			]
			result = dict
		case .sizeValue(let src):
			let dict: Dictionary<String, CNValue> = [
				"width":	.numberValue(NSNumber(value: Double(src.width))),
				"height":	.numberValue(NSNumber(value: Double(src.height)))
			]
			result = dict
		case .rectValue(let src):
			let dict: Dictionary<String, CNValue> = [
				"x":		.numberValue(NSNumber(value: Double(src.origin.x))),
				"y":		.numberValue(NSNumber(value: Double(src.origin.y))),
				"width":	.numberValue(NSNumber(value: Double(src.size.width))),
				"height":	.numberValue(NSNumber(value: Double(src.size.height)))
			]
			result = dict
		case .dictionaryValue(let src):
			result = src
		case .colorValue(let src):
			let dict: Dictionary<String, CNValue> = [
				"alpha":	.numberValue(NSNumber(value: Double(src.alphaComponent))),
				"red":		.numberValue(NSNumber(value: Double(src.redComponent))),
				"blue":		.numberValue(NSNumber(value: Double(src.blueComponent))),
				"green":	.numberValue(NSNumber(value: Double(src.greenComponent)))
			]
			result = dict
		case .enumValue(let typename, let value):
			let dict: Dictionary<String, CNValue> = [
				"type":		.stringValue(typename),
				"value":	.numberValue(NSNumber(value: value))
			]
			result = dict
		}
		return result
	}

	public static func dictionaryToValue(dictionary dict: Dictionary<String, CNValue>) -> CNValue {
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
			/* Decode enum */
			if let tval = dict["type"], let vval = dict["value"] {
				if let tstr = tval.toString(), let vnum = vval.toNumber() {
					let typename = tstr
					let value    = vnum.int32Value
					return .enumValue(typename, value)
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
