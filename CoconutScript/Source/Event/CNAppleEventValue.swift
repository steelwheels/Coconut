/**
 * @file	CNAppleEventValue.swift
 * @brief	Define CNAppleEventValue class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

/* Reference: http://frontierkernel.sourceforge.net/cgi-bin/lxr/source/Common/headers/macconv.h
 *	      https://sites.google.com/site/zzaatrans/home/releasenotes/applescript/asterminology_appleeventcodes/termsandcodes_code-html
 */
public enum CNAppleEventKeyword: CaseIterable {
	case answer
	case appleEvent
	case application
	case coreSuite
	case createElement
	case directObject
	case desiredClass
	case document
	case getData
	case enumerate
	case errorNumber
	case errorString
	case format
	case from
	case frontmost
	case height
	case index
	case length
	case location
	case null
	case objectClass
	case objectName
	case objectSpecifier
	case origin
	case property
	case propertyData
	case propertyName
	case selectData
	case size
	case quit
	case position_x
	case position_y
	case text
	case type
	case unicodeText
	case width
	case window

	public func toString() -> String {
		let result: String
		switch self {
		case .answer:		result = "ansr"
		case .appleEvent:	result = "aevt"
		case .application:	result = "capp"
		case .coreSuite:	result = "core"
		case .createElement:	result = "crel"
		case .desiredClass:	result = "want"
		case .directObject:	result = "----"
		case .document:		result = "docu"
		case .enumerate:	result = "enum"
		case .format:		result = "form"
		case .from:		result = "from"
		case .frontmost:	result = "pisf"
		case .getData:		result = "getd"
		case .errorNumber:	result = "errn"
		case .errorString:	result = "errs"
		case .height:		result = "hght"		// custom
		case .index:		result = "indx"
		case .length:		result = "leng"		// custom
		case .location:		result = "loct"		// custom
		case .null:		result = "null"
		case .objectClass:	result = "kocl"
		case .objectName:	result = "name"
		case .objectSpecifier:	result = "obj "
		case .origin:		result = "orgn"		// custom
		case .position_x:	result = "posx"		// custom
		case .position_y:	result = "posy"		// custom
		case .property:		result = "prop"
		case .propertyData:	result = "prdt"
		case .propertyName:	result = "pnam"
		case .selectData:	result = "seld"
		case .quit:		result = "quit"
		case .size:		result = "size"		// custom
		case .text:		result = "ctxt"
		case .type:		result = "type"
		case .unicodeText:	result = "utxt"
		case .width:		result = "wdth"		// custom
		case .window:		result = "cwin"
		}
		return result
	}

	public static func encode(string str: String) -> CNAppleEventKeyword? {
		for elm in CNAppleEventKeyword.allCases {
			if elm.toString() == str {
				return elm
			}
		}
		return nil
	}

	public static func encode(keyword key: AEKeyword) -> CNAppleEventKeyword? {
		for elm in CNAppleEventKeyword.allCases {
			if elm.code() == key {
				return elm
			}
		}
		return nil
	}

	public func code() -> AEKeyword {
		var result: UInt32 = 0
		let codestr = self.toString()
		var idx     = codestr.startIndex
		let end     = codestr.endIndex
		while idx < end {
			if let ascii = codestr[idx].asciiValue {
				result = (result << 8) | (UInt32(ascii) & 0xff)
			} else {
				NSLog("Failed to convert to ascrii: \(codestr)")
			}
			idx = codestr.index(after: idx)
		}
		return result
	}
}

public extension NSAppleEventDescriptor
{
	func setRecord(intValue ival: Int32, forKeyword key: CNAppleEventKeyword) {
		let val = NSAppleEventDescriptor(int32: ival)
		self.setDescriptor(val, forKeyword: key.code())
	}

	func setRecord(enumValue eval: OSType, forKeyword key: CNAppleEventKeyword) {
		let val = NSAppleEventDescriptor(enumCode: eval)
		self.setDescriptor(val, forKeyword: key.code())
	}

	func setRecord(descriptor desc: NSAppleEventDescriptor, forKeyword key: CNAppleEventKeyword) {
		self.setDescriptor(desc, forKeyword: key.code())
	}

	func setParameter(value val: CNNativeValue, forKeyword key: CNAppleEventKeyword){
		self.setParam(val.toEventDescriptor(), forKeyword: key.code())
	}
}

public extension CNNativeValue
{
	func toEventDescriptor() -> NSAppleEventDescriptor {
		let result: NSAppleEventDescriptor
		switch self {
		case .nullValue:
			result = NSAppleEventDescriptor()
		case .numberValue(let val):
			/* The floating point is NOT supported */
			result = NSAppleEventDescriptor(int32: val.int32Value)
		case .stringValue(let val):
			result = NSAppleEventDescriptor(string: val)
		case .dateValue(let val):
			result = NSAppleEventDescriptor(date: val)
		case .rangeValue(let val):
			result = NSAppleEventDescriptor.record()
			result.setRecord(intValue: Int32(val.location), forKeyword: .location)
			result.setRecord(intValue: Int32(val.length),   forKeyword: .length)
		case .pointValue(let val):
			result = CNNativeValue.pointToDescriptor(point: val)
		case .sizeValue(let val):
			result = CNNativeValue.sizeToDescriptor(size: val)
		case .rectValue(let val):
			let pt = CNNativeValue.pointToDescriptor(point: val.origin)
			let sz = CNNativeValue.sizeToDescriptor(size: val.size)
			result = NSAppleEventDescriptor.record()
			result.setRecord(descriptor: pt, forKeyword: .origin)
			result.setRecord(descriptor: sz, forKeyword: .size)
		case .enumValue(_, let val):
			result = NSAppleEventDescriptor(enumCode: OSType(val))
		case .dictionaryValue(let dict):
			result = NSAppleEventDescriptor.record()
			for (key, val) in dict {
				if let ekey = CNAppleEventKeyword.encode(string: key) {
					let data = val.toEventDescriptor()
					result.setRecord(descriptor: data, forKeyword: ekey)
				} else {
					NSLog("Unknown apple event: \(key)")
				}
			}
		case .arrayValue(let arr):
			result  = NSAppleEventDescriptor.list()
			var idx = 0
			for elm in arr {
				let data = elm.toEventDescriptor()
				result.insert(data, at: idx)
				idx += 1
			}
			return result
		case .URLValue(let val):
			result = NSAppleEventDescriptor(fileURL: val)
		case .imageValue(_), .anyObjectValue(_):
			fatalError("\(#file): Unsupported error")
		}
		return result
	}

	private static func pointToDescriptor(point pt: CGPoint) -> NSAppleEventDescriptor {
		let result = NSAppleEventDescriptor.record()
		result.setRecord(intValue: Int32(pt.x), forKeyword: .position_x)
		result.setRecord(intValue: Int32(pt.y), forKeyword: .position_y)
		return result
	}

	private static func sizeToDescriptor(size sz: CGSize) -> NSAppleEventDescriptor {
		let result = NSAppleEventDescriptor.record()
		result.setRecord(intValue: Int32(sz.width),  forKeyword: .width)
		result.setRecord(intValue: Int32(sz.height), forKeyword: .height)
		return result
	}
}

