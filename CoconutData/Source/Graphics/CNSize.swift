/**
 * @file	CNSize.swift
 * @brief	Extend CGSize class
 * @par Copyright
 *   Copyright (C) 2016-2021 Steel Wheels Project
 */

import CoreGraphics
import Foundation

public extension CGSize
{
	static let ClassName = "size"

	static func fromValue(value val: CNValue) -> CGSize? {
		if let dict = val.toDictionary() {
			return fromValue(value: dict)
		} else {
			return nil
		}
	}

	static func fromValue(value val: Dictionary<String, CNValue>) -> CGSize? {
		if let wval = val["width"], let hval = val["height"] {
			if let wnum = wval.toNumber(), let hnum = hval.toNumber() {
				let width  : CGFloat = CGFloat(wnum.doubleValue)
				let height : CGFloat = CGFloat(hnum.doubleValue)
				return CGSize(width: width, height: height)
			}
		}
		return nil
	}

	func toValue() -> Dictionary<String, CNValue> {
		let wnum = NSNumber(floatLiteral: Double(self.width))
		let hnum = NSNumber(floatLiteral: Double(self.height))
		let result: Dictionary<String, CNValue> = [
			"class":  .stringValue(CGSize.ClassName),
			"width":  .numberValue(wnum),
			"height": .numberValue(hnum)
		]
		return result
	}

	func resizeWithKeepingAscpect(inWidth dstwidth: CGFloat) -> CGSize {
		guard dstwidth > 0.0 && self.width > 0.0 && self.height > 0.0 else {
			CNLog(logLevel: .error, message: "Invalid size", atFunction: #function, inFile: #file)
			return self
		}
		let ratio = self.width / self.height
		let newwidth  = dstwidth
		let newheight = dstwidth / ratio
		return CGSize(width: newwidth, height: newheight)
	}

	func resizeWithKeepingAscpect(inSize dst: CGSize) -> CGSize {
		guard dst.width > 0.0 && dst.height > 0.0 else {
			CNLog(logLevel: .error, message: "Invalid size", atFunction: #function, inFile: #file)
			return self
		}
		let reswidth, resheight: CGFloat
		let ratio = self.width / self.height
		if ratio >= 1.0 {
			/* width >= height */
			reswidth  = dst.width
			resheight = dst.width / ratio
		} else {
			/* width < height */
			reswidth  = dst.height * ratio
			resheight = dst.height
		}
		return CGSize(width: reswidth, height: resheight)
	}

	var description: String {
		get {
			let wstr = NSString(format: "%.2lf", self.width)
			let hstr = NSString(format: "%.2lf", self.height)
			return "{width:\(wstr), height:\(hstr)}"
		}
	}
}

public func CNMaxSize(sizeA a: CGSize, sizeB b: CGSize) -> CGSize
{
	let width  = max(a.width,  b.width)
	let height = max(a.height, b.height)
	return CGSize(width: width, height: height)
}

public func CNMinSize(sizeA a: CGSize, sizeB b: CGSize) -> CGSize
{
	let width  = min(a.width,  b.width)
	let height = min(a.height, b.height)
	return CGSize(width: width, height: height)
}

public func CNExpandSize(size sz: CGSize, byInsets insets: CNEdgeInsets) -> CGSize {
	let width  = insets.left + sz.width  + insets.right
	let height = insets.top  + sz.height + insets.bottom
	return CGSize(width: width, height: height)
}

public func CNShrinkSize(size sz: CGSize, delta dlt: CGFloat) -> CGSize {
	let width  = max(sz.width  - dlt * 2.0, 0.0)
	let height = max(sz.height - dlt * 2.0, 0.0)
	return CGSize(width: width, height: height)
}

public func CNUnionSize(sizeA a: CGSize, sizeB b: CGSize, doVertical vert: Bool, spacing space: CGFloat) -> CGSize
{
	if vert {
		let width  = max(a.width, b.width)
		let height = a.height + b.height + space
		return CGSize(width: width, height: height)
	} else {
		let width  = a.width + b.width + space
		let height = max(a.height, b.height)
		return CGSize(width: width, height: height)
	}
}


