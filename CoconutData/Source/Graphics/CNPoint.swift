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
	static let InterfaceName = "PointIF"

	static func allocateInterfaceType() -> CNInterfaceType {
		let ptypes: Dictionary<String, CNValueType> = [
			"x":	.numberType,
			"y":	.numberType
		]
		return CNInterfaceType(name: InterfaceName, base: nil, types: ptypes)
	}

	static func fromValue(value val: CNInterfaceValue) -> CGPoint? {
		guard val.type.name == InterfaceName else {
			return nil
		}
		if let xval = val.get(name: "x"), let yval = val.get(name: "y") {
			if let xnum = xval.toNumber(), let ynum = yval.toNumber() {
				let x:CGFloat = CGFloat(xnum.floatValue)
				let y:CGFloat = CGFloat(ynum.floatValue)
				return CGPoint(x: x, y: y)
			}
		}
		return nil
	}

	func toValue() -> CNInterfaceValue {
		let iftype: CNInterfaceType
		if let typ = CNInterfaceTable.currentInterfaceTable().search(byTypeName: CGPoint.InterfaceName) {
			iftype = typ
		} else {
			CNLog(logLevel: .error, message: "No interface type: \"\(CGPoint.InterfaceName)\"",
			      atFunction: #function, inFile: #file)
			iftype = CNInterfaceType.nilType
		}

		let xnum = NSNumber(floatLiteral: Double(self.x))
		let ynum = NSNumber(floatLiteral: Double(self.y))
		let pvalues: Dictionary<String, CNValue> = [
			"x"     : .numberValue(xnum),
			"y"     : .numberValue(ynum)
		]
		return CNInterfaceValue(types: iftype, values: pvalues)
	}

	func moving(dx x: CGFloat, dy y: CGFloat) -> CGPoint {
		let newx = self.x + x
		let newy = self.y + y
		return CGPoint(x: newx, y: newy)
	}

	func subtracting(_ p: CGPoint) -> CGPoint {
		return CGPoint(x: self.x - p.x, y: self.y - p.y)
	}

	var description: String { get {
		let xstr = NSString(format: "%.2lf", Double(self.x))
		let ystr = NSString(format: "%.2lf", Double(self.y))
		return "{x:\(xstr), y:\(ystr)}"
	}}

	static func center(_ pt0: CGPoint, _ pt1: CGPoint) -> CGPoint {
		let x = (pt0.x + pt1.x) / 2.0
		let y = (pt0.y + pt1.y) / 2.0
		return CGPoint(x: x, y: y)
	}
}


