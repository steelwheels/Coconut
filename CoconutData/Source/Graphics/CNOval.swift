/**
 * @file	CNOval.swift
 * @brief	Define CNOval class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoreGraphics
import Foundation

public struct CNOval
{
	public static let ClassName = "oval"

	private var mCenter:	CGPoint
	private var mRadius:	CGFloat

	public init(center ctr: CGPoint, radius rad: CGFloat){
		mCenter		= ctr
		mRadius		= rad
	}

	public init?(value val: Dictionary<String, CNValue>) {
		if let centerval = val["center"], let radval = val["radius"] {
			if let centerdict = centerval.toDictionary(), let radius = radval.toNumber() {
				if let center = CGPoint(value: centerdict) {
					self.init(center: center, radius: CGFloat(radius.floatValue))
					return
				}
			}
		}
		return nil
	}

	public func toValue() -> Dictionary<String, CNValue> {
		let center = mCenter.toValue()
		let radius = NSNumber(floatLiteral: Double(mRadius))
		let result: Dictionary<String, CNValue> = [
			"class"		: .stringValue(CNOval.ClassName),
			"center"	: .dictionaryValue(center),
			"radius"	: .numberValue(radius)
		]
		return result
	}

	public var center: CGPoint { get { return mCenter }}

	public var upperCenter: CGPoint { get {
		let result: CGPoint
		#if os(OSX)
			result = CGPoint(x: mCenter.x, y: mCenter.y + mRadius)
		#else
			result = CGPoint(x: mCenter.x, y: mCenter.y - mRadius)
		#endif
		return result
	}}

	public var lowerCenter: CGPoint { get {
		let result: CGPoint
		#if os(OSX)
			result = CGPoint(x: mCenter.x, y: mCenter.y - mRadius)
		#else
			result = CGPoint(x: mCenter.x, y: mCenter.y + mRadius)
		#endif
		return result
	}}

	public var middleLeft: CGPoint { get {
		return CGPoint(x: mCenter.x - mRadius, y: mCenter.y)
	}}

	public var middleRight: CGPoint { get {
		return CGPoint(x: mCenter.x + mRadius, y: mCenter.y)
	}}
}


