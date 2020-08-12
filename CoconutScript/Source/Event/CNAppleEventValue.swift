/**
 * @file	CNAppleEventValue.swift
 * @brief	Define CNAppleEventValue class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

public extension NSAppleEventDescriptor
{
	func set(intValue ival: Int32, forKeyword key: String) {
		let word = NSAppleEventDescriptor.codeValue(code: key)
		let val  = NSAppleEventDescriptor(int32: ival)
		self.setDescriptor(val, forKeyword: word)
	}

	func set(descriptor desc: NSAppleEventDescriptor, forKeyword key: String) {
		let word = NSAppleEventDescriptor.codeValue(code: key)
		self.setDescriptor(desc, forKeyword: word)
	}

	static func codeValue(code codestr: String) -> AEKeyword {
		var result: UInt32 = 0
		var idx = codestr.startIndex
		let end = codestr.endIndex
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
			result.set(intValue: Int32(val.location), forKeyword: "loc")
			result.set(intValue: Int32(val.length),   forKeyword: "len")
		case .pointValue(let val):
			result = CNNativeValue.pointToDescriptor(point: val)
		case .sizeValue(let val):
			result = CNNativeValue.sizeToDescriptor(size: val)
		case .rectValue(let val):
			let pt = CNNativeValue.pointToDescriptor(point: val.origin)
			let sz = CNNativeValue.sizeToDescriptor(size: val.size)
			result = NSAppleEventDescriptor.record()
			result.set(descriptor: pt, forKeyword: "orgn")
			result.set(descriptor: sz, forKeyword: "size")
		case .dictionaryValue(let dict):
			result = NSAppleEventDescriptor.record()
			for (key, val) in dict {
				let word = NSAppleEventDescriptor.codeValue(code: key)
				let data = val.toEventDescriptor()
				result.setDescriptor(data, forKeyword: word)
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
		result.set(intValue: Int32(pt.x), forKeyword: "x   ")
		result.set(intValue: Int32(pt.y), forKeyword: "y   ")
		return result
	}

	private static func sizeToDescriptor(size sz: CGSize) -> NSAppleEventDescriptor {
		let result = NSAppleEventDescriptor.record()
		result.set(intValue: Int32(sz.width),  forKeyword: "wdth")
		result.set(intValue: Int32(sz.height), forKeyword: "hght")
		return result
	}
}
