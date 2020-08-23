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
	static func fromColor(color col: CNColor) -> NSAppleEventDescriptor {
		let (r, g, b, a) = col.toRGBA()
		let newdesc = NSAppleEventDescriptor.list()
		newdesc.insert(NSAppleEventDescriptor(double: Double(r)), at: 1)
		newdesc.insert(NSAppleEventDescriptor(double: Double(g)), at: 2)
		newdesc.insert(NSAppleEventDescriptor(double: Double(b)), at: 3)
		newdesc.insert(NSAppleEventDescriptor(double: Double(a)), at: 4)
		return newdesc
	}

	func toColor() -> CNColor? {
		if let e1 = self.atIndex(1), let e2 = self.atIndex(2), let e3 = self.atIndex(3), let e4 = self.atIndex(4) {
			let r = CGFloat(e1.doubleValue)
			let g = CGFloat(e2.doubleValue)
			let b = CGFloat(e3.doubleValue)
			let a = CGFloat(e4.doubleValue)
			return CNColor(red: r, green: g, blue: b, alpha: a)
		} else {
			return nil
		}
	}

	func setResult(resultValue retval: NSAppleEventDescriptor?, error str: String?){
		if let retobj = retval {
			self.setDirectParameter(retobj)
		}
		if let s = str {
			/* Set error message */
			let strobj = NSAppleEventDescriptor(string: s)
			self.setParam(strobj, forKeyword: CNEventResult.errorString.code())
			/* Set error count = 1 */
			let numobj = NSAppleEventDescriptor(int32: 1)
			self.setParam(numobj, forKeyword: CNEventResult.errorCount.code())
		} else {
			/* Set error count = 0 */
			let numobj = NSAppleEventDescriptor(int32: 0)
			self.setParam(numobj, forKeyword: CNEventResult.errorCount.code())
		}
	}

	var directParameter: NSAppleEventDescriptor? {
		get { return self.forKeyword(CNEventDescripton.directObject.code()) }
	}

	func setDirectParameter(_ param: NSAppleEventDescriptor) {
		self.setParam(param, forKeyword: CNEventDescripton.directObject.code())
	}

	var dataParameter: NSAppleEventDescriptor? {
		get { return self.forKeyword(CNEventDescripton.data.code()) }
	}

	func setDataParameter(_ param: NSAppleEventDescriptor) {
		self.setParam(param, forKeyword: CNEventDescripton.data.code())
	}

	var format: CNEventFormat? {
		get {
			if let formobj = self.forKeyword(CNEventDescripton.format.code()) {
				if let formstr = formobj.stringValue {
					return CNEventFormat.encode(string: formstr)
				}
			}
			return nil
		}
	}

	var selectDataName: OSType? {
		get {
			if let seldobj = self.forKeyword(CNEventDescripton.selectData.code()) {
				return seldobj.enumCodeValue
			}
			return nil
		}
	}
}

#endif // os(OSX)

