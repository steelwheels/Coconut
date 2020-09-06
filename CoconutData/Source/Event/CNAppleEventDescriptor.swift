/**
 * @file	CNAppleEventDescriptor.swift
 * @brief	Extend NSAppleEventDescriptor class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

#if os(OSX)

public extension NSAppleEventDescriptor
{
	static func object() -> NSAppleEventDescriptor? {
		/* Allocate record but it has object specifier */
		return NSAppleEventDescriptor.record().coerce(toDescriptorType: CNEventCode.object.code())
	}

	func setResult(resultValue retval: NSAppleEventDescriptor?, error str: String?){
		if let retobj = retval {
			self.setParam(retobj, forKeyword: CNEventCode.directObject.code())
		}
		if let s = str {
			/* Set error message */
			let strobj = NSAppleEventDescriptor(string: s)
			self.setParam(strobj, forKeyword: CNEventCode.errorString.code())
			/* Set error count = 1 */
			let numobj = NSAppleEventDescriptor(int32: 1)
			self.setParam(numobj, forKeyword: CNEventCode.errorCount.code())
		} else {
			/* Set error count = 0 */
			let numobj = NSAppleEventDescriptor(int32: 0)
			self.setParam(numobj, forKeyword: CNEventCode.errorCount.code())
		}
	}

	func toValue() -> CNValue? {
		let result: CNValue?
		
		switch self.descriptorType {
		case CNEventCode.bool.code():
			result = CNValue(booleanValue: self.booleanValue)
		case CNEventCode.short.code(), CNEventCode.long.code():
			result = CNValue(intValue: Int(self.int32Value))
		case CNEventCode.float.code(), CNEventCode.double.code():
			result = CNValue(doubleValue: self.doubleValue)
		case CNEventCode.text.code():
			if let str = self.stringValue {
				result = CNValue(stringValue: str)
			} else {
				result = nil
			}
		case CNEventCode.trueValue.code():
			result = CNValue(booleanValue: true)
		case CNEventCode.falseValue.code():
			result = CNValue(booleanValue: false)
		default:
			result = nil
		}
		return result
	}

	func toColor() -> CNColor? {
		if let e1 = self.atIndex(1), let e2 = self.atIndex(2), let e3 = self.atIndex(3) {
			let r = CGFloat(e1.doubleValue)
			let g = CGFloat(e2.doubleValue)
			let b = CGFloat(e3.doubleValue)
			let a = CGFloat(1.0)
			return CNColor(red: r, green: g, blue: b, alpha: a)
		} else {
			return nil
		}
	}
}

public extension CNColor
{
	func toEventDescriptor() -> NSAppleEventDescriptor? {
		/*
		if let data = self.toData() {
			return NSAppleEventDescriptor(descriptorType: CNEventCode.color.code(), data: data)
		} else {
			return nil
		}*/
		let (r, g, b, _) = self.toRGBA()
		let newdesc = NSAppleEventDescriptor.list()
		newdesc.insert(NSAppleEventDescriptor(double: Double(r)), at: 1)
		newdesc.insert(NSAppleEventDescriptor(double: Double(g)), at: 2)
		newdesc.insert(NSAppleEventDescriptor(double: Double(b)), at: 3)
		//newdesc.insert(NSAppleEventDescriptor(double: Double(a)), at: 4)
		return newdesc
	}
}

#endif // os(OSX)

