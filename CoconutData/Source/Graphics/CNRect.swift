/**
 * @file	CNRect.swift
 * @brief	Extend CGRect class
 * @par Copyright
 *   Copyright (C) 2016-2021 Steel Wheels Project
 */

import CoreGraphics
import Foundation

public extension CGRect
{
	var center: CGPoint { get {
		let x = self.origin.x + (self.size.width  / 2)
		let y = self.origin.y + (self.size.height / 2)
		return CGPoint(x: x, y:y)
	}}

	var upperLeftPoint: CGPoint { get {
		let result: CGPoint
		#if os(OSX)
			result = CGPoint(x: self.origin.x, y: self.origin.y + self.size.height)
		#else
			result = self.origin
		#endif
		return result
	}}

	var upperRightPoint: CGPoint { get {
		let result: CGPoint
		#if os(OSX)
			result = CGPoint(x: self.origin.x + self.size.width, y: self.origin.y + self.size.height)
		#else
			result = CGPoint(x: self.origin.x + self.size.width, y: self.origin.y)
		#endif
		return result
	}}

	var lowerLeftPoint: CGPoint { get {
		let result: CGPoint
		#if os(OSX)
			result = self.origin
		#else
			result = CGPoint(x: self.origin.x, y: self.origin.y + self.size.height)
		#endif
		return result
	}}

	var lowerRightPoint: CGPoint { get {
		let result: CGPoint
		#if os(OSX)
			result = CGPoint(x: self.origin.x + self.size.width, y: self.origin.y)
		#else
			result = CGPoint(x: self.origin.x + self.size.width, y: self.origin.y + self.size.height)
		#endif
		return result
	}}

	func centeringIn(bounds bnds: CGRect) -> CGRect {
		let dx = (bnds.size.width  - self.size.width ) / 2.0
		let dy = (bnds.size.height - self.size.height) / 2.0
		let neworigin = CGPoint(x: bnds.origin.x + dx, y: bnds.origin.y + dy)
		return CGRect(origin: neworigin, size: self.size)
	}

	func resize(size s:CGSize) -> CGRect {
		return CGRect(origin: self.origin, size: s)
	}

	func move(dx x: CGFloat, dy y: CGFloat) -> CGRect {
		let neworigin = self.origin.moving(dx: x, dy: y)
		return CGRect(origin: neworigin, size: self.size)
	}

	func splitByHorizontally() -> (CGRect, CGRect) {
		let width   = self.size.width
		let height  = self.size.height / 2.0
		let origin0 = self.origin
		let origin1 = CGPoint(x: origin0.x, y: origin0.y + height)
		let size    = CGSize(width: width, height: height)
		return (CGRect(origin: origin0, size: size), CGRect(origin: origin1, size: size))
	}

	func splitByVertically() -> (CGRect, CGRect) {
		let width   = self.size.width / 2.0
		let height  = self.size.height
		let origin0 = self.origin
		let origin1 = CGPoint(x: origin0.x + width, y: origin0.y)
		let size    = CGSize(width: width, height: height)
		return (CGRect(origin: origin0, size: size), CGRect(origin: origin1, size: size))
	}

	static func insideRect(rect rct: CGRect, spacing space: CGFloat) -> CGRect {
		let margin = space * 2.0
		if rct.size.width < margin || rct.size.height < margin {
			return rct
		} else {
			let x	   = rct.origin.x + space
			let y	   = rct.origin.y + space
			let width  = rct.size.width  - margin
			let height = rct.size.height - margin
			return CGRect(x: x, y: y, width: width, height: height)
		}
	}

	static func outsideRect(rect rct: CGRect, spacing space: CGFloat) -> CGRect {
		let margin = space * 2.0
		let x	   = max(rct.origin.x - space, 0.0)
		let y	   = max(rct.origin.y - space, 0.0)
		let width  = rct.size.width  + margin
		let height = rct.size.height + margin
		return CGRect(x: x, y: y, width: width, height: height)
	}

	static func pointsToRect(fromPoint fp:CGPoint, toPoint tp:CGPoint) -> CGRect {
		var x, y, width, height: CGFloat
		if fp.x >= tp.x {
			x     = tp.x
			width = fp.x - tp.x
		} else {
			x     = fp.x
			width = tp.x - fp.x
		}
		if fp.y >= tp.y {
			y      = tp.y
			height = fp.y - tp.y
		} else {
			y      = fp.y
			height = tp.y - fp.y
		}
		return CGRect(x: x, y: y, width: width, height: height)
	}

	var description: String {
		let ostr = origin.description
		let sstr = size.description
		return "{origin:\(ostr) size:\(sstr)}"
	}
}
