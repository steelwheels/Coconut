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
	case	recordType
	case	objectType
	case	referenceType

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
		case .recordType:	result = "Record"
		case .objectType:	result = "Object"
		case .referenceType:	result = "Reference"
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

	/* Return true when the value has single data */
	public static func isPrimitive(type typ: CNValueType) -> Bool {
		let result: Bool
		switch typ {
		case .nullType, .boolType, .numberType, .stringType, .dateType, .URLType, .imageType, .objectType:
			result = true
		case .rangeType, .pointType, .sizeType, .rectType, .enumType, .dictionaryType, .arrayType, .colorType, .recordType, .referenceType:
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
	case enumValue(_ val: CNEnum)
	case dictionaryValue(_ val: Dictionary<String, CNValue>)
	case arrayValue(_ val: Array<CNValue>)
	case URLValue(_ val: URL)
	case colorValue(_ val: CNColor)
	case imageValue(_ val: CNImage)
	case recordValue(_ val: CNRecord)
	case objectValue(_ val: NSObject)
	case reference(_ val: CNValueReference)

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
			case .enumValue(_):		result = .enumType
			case .dictionaryValue(_):	result = .dictionaryType
			case .arrayValue(_):		result = .arrayType
			case .URLValue(_):		result = .URLType
			case .colorValue(_):		result = .colorType
			case .imageValue(_):		result = .imageType
			case .recordValue(_):		result = .recordType
			case .objectValue(_):		result = .objectType
			case .reference(_):		result = .referenceType
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
		case .rangeValue(let range):		result = range
		case .dictionaryValue(let dict):	result = NSRange.fromValue(value: dict)
		default:				result = nil
		}
		return result
	}

	public func toPoint() -> CGPoint? {
		let result: CGPoint?
		switch self {
		case .pointValue(let pt):		result = pt
		case .dictionaryValue(let dict):	result = CGPoint.fromValue(value: dict)
		default:				result = nil
		}
		return result
	}

	public func toSize() -> CGSize? {
		let result: CGSize?
		switch self {
		case .sizeValue(let size):		result = size
		case .dictionaryValue(let dict):	result = CGSize.fromValue(value: dict)
		default:				result = nil
		}
		return result
	}

	public func toRect() -> CGRect? {
		let result: CGRect?
		switch self {
		case .rectValue(let rect):		result = rect
		case .dictionaryValue(let dict):	result = CGRect.fromValue(value: dict)
		default:				result = nil
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
		case .colorValue(let col):		result = col
		case .dictionaryValue(let dict):	result = CNColor.fromValue(value: dict)
		default:				result = nil
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

	public func toRecord() -> CNRecord? {
		let result: CNRecord?
		switch self {
		case .recordValue(let obj):	result = obj
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

	public func toReference() -> CNValueReference? {
		let result: CNValueReference?
		switch self {
		case .reference(let obj):	result = obj
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

	public func recordProperty(identifier ident: String) -> CNRecord? {
		if let elm = valueProperty(identifier: ident){
			return elm.toRecord()
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

	public func referenceProperty(identifier ident: String) -> CNValueReference? {
		if let elm = valueProperty(identifier: ident){
			return elm.toReference()
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
		     .sizeValue(_), .rectValue(_), .enumValue(_), .URLValue(_), .colorValue(_),
		     .imageValue(_), .objectValue(_), .reference(_):
			result = false
		case .stringValue(let str):
			result = str.isEmpty
		case .dictionaryValue(let dict):
			result = dict.count == 0
		case .arrayValue(let arr):
			result = arr.count == 0
		case .recordValue(let rec):
			result = rec.fieldCount == 0
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
		case .enumValue(let val):
			result = dictionaryToText(dictionary: val.toValue())
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
			result = dictionaryToText(dictionary: val.toValue())
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
		case .recordValue(let val):
			result = dictionaryToText(dictionary: val.toValue())
		case .objectValue(let val):
			let classname = String(describing: type(of: val))
			result = CNTextLine(string: "object(\(classname))")
		case .reference(let val):
			result = dictionaryToText(dictionary: val.toValue())
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
		case .enumValue(let val):
			result = val.toValue()
		case .rangeValue(let val):
			result = val.toValue()
		case .pointValue(let val):
			result = val.toValue()
		case .sizeValue(let val):
			result = val.toValue()
		case .rectValue(let val):
			result = val.toValue()
		case .URLValue(let val):
			result = val
		case .colorValue(let val):
			result = val.toValue()
		case .imageValue(let val):
			result = val
		case .objectValue(let val):
			result = val
		case .recordValue(let val):
			result = val
		case .reference(let val):
			result = val
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
		} else if let val = obj as? URL {
			result = .URLValue(val)
		} else if let val = obj as? CNColor {
			result = .colorValue(val)
		} else if let val = obj as? CNImage {
			result = .imageValue(val)
		} else if let val = obj as? CNRecord {
			result = .recordValue(val)
		} else if let val = obj as? CNValueReference {
			result = .reference(val)
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
		case .referenceType:
			result = .reference(CNValueReference(relativePath: src))
		case .rangeType, .pointType, .sizeType, .rectType, .enumType, .dictionaryType, .arrayType,
		     .colorType, .imageType, .recordType, .objectType:
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
			result = src.toValue()
		case .pointValue(let src):
			result = src.toValue()
		case .sizeValue(let src):
			result = src.toValue()
		case .rectValue(let src):
			result = src.toValue()
		case .dictionaryValue(let src):
			result = src
		case .colorValue(let src):
			result = src.toValue()
		case .enumValue(let src):
			result = src.toValue()
		case .recordValue(let src):
			result = src.toValue()
		case .reference(let src):
			result = src.toValue()
		}
		return result
	}

	public static func dictionaryToValue(dictionary dict: Dictionary<String, CNValue>) -> CNValue? {
		var result: CNValue? = nil
		if let clsval = dict["class"] {
			if let clsname = clsval.toString() {
				switch clsname {
				case CGPoint.ClassName:
					if let point = CGPoint.fromValue(value: dict) {
						result = .pointValue(point)
					}
				case CGRect.ClassName:
					if let rect = CGRect.fromValue(value: dict) {
						result = .rectValue(rect)
					}
				case CGSize.ClassName:
					if let size = CGSize.fromValue(value: dict) {
						result = .sizeValue(size)
					}
				case CNColor.ClassName:
					if let color = CNColor.fromValue(value: dict) {
						result = .colorValue(color)
					}
				case CNEnum.ClassName:
					if let eval = CNEnum.fromValue(value: dict) {
						result = .enumValue(eval)
					}
				case NSRange.ClassName:
					if let range = NSRange.fromValue(value: dict) {
						result = .rangeValue(range)
					}
				case CNRecord.ClassName:
					if let record = CNRecord.fromValue(value: dict) {
						result = .recordValue(record)
					}
				case CNValueReference.ClassName:
					if let ref = CNValueReference.fromValue(value: dict) {
						result = .reference(ref)
					}
				default:
					break
				}
			}
		}
		return result
	}
}
