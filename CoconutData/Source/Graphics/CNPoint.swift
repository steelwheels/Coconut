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
	func moving(dx x: CGFloat, dy y: CGFloat) -> CGPoint {
		let newx = self.x + x
		let newy = self.y + y
		return CGPoint(x: newx, y: newy)
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

public func == (left: CGPoint, right: CGPoint) -> Bool {
	return (left.x == right.x) && (left.y == right.y)
}

public func != (left: CGPoint, right: CGPoint) -> Bool {
	return (left.x != right.x) || (left.y != right.y)
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
	return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
	return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func * (left: CGPoint, right: CGFloat) -> CGPoint {
	return CGPoint(x: left.x * right, y: left.y * right)
}

public func * (left: CGFloat, right: CGPoint) -> CGPoint {
	return CGPoint(x:left * right.x, y:left * right.y)
}

public func / (left: CGPoint, right: CGFloat) -> CGPoint {
	return CGPoint(x:left.x / right, y:left.y / right)
}

