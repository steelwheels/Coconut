/**
 * @file	CNPoint.swift
 * @brief	Extend CGPoint class
 * @par Copyright
 *   Copyright (C) 2016-2021 Steel Wheels Project
 */

import CoreGraphics
import Foundation

public extension CGPoint
{
	static let ClassName = "point"

	init?(value val: Dictionary<String, CNValue>) {
		if let xval = val["x"], let yval = val["y"] {
			if let xnum = xval.toNumber(), let ynum = yval.toNumber() {
				let x:CGFloat = CGFloat(xnum.floatValue)
				let y:CGFloat = CGFloat(ynum.floatValue)
				self.init(x: x, y: y)
				return
			}
		}
		return nil
	}

	init?(value val: CNValue){
		if let dict = val.toDictionary() {
			self.init(value: dict)
			return
		} else {
			return nil
		}
	}

	func toValue() -> Dictionary<String, CNValue> {
		let xnum = NSNumber(floatLiteral: Double(self.x))
		let ynum = NSNumber(floatLiteral: Double(self.y))
		let result: Dictionary<String, CNValue> = [
			"class" : .stringValue(CGPoint.ClassName),
			"x"     : .numberValue(xnum),
			"y"     : .numberValue(ynum)
		]
		return result
	}

	func moving(dx x: CGFloat, dy y: CGFloat) -> CGPoint {
		let newx = self.x + x
		let newy = self.y + y
		return CGPoint(x: newx, y: newy)
	}

	func subtracting(_ p: CGPoint) -> CGPoint {
		return CGPoint(x: self.x - p.x, y: self.y - p.y)
	}

	var description: String {
		get {
			let xstr = NSString(format: "%.2lf", Double(self.x))
			let ystr = NSString(format: "%.2lf", Double(self.y))
			return "{x:\(xstr), y:\(ystr)}"
		}
	}

	static func center(_ pt0: CGPoint, _ pt1: CGPoint) -> CGPoint {
		let x = (pt0.x + pt1.x) / 2.0
		let y = (pt0.y + pt1.y) / 2.0
		return CGPoint(x: x, y: y)
	}
}


