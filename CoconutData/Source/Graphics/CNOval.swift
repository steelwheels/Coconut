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
	public static let ClassName = "Oval"

	private var mCenter:	CGPoint
	private var mRadius:	CGFloat

	public init(center ctr: CGPoint, radius rad: CGFloat){
		mCenter		= ctr
		mRadius		= rad
	}

	public static func fromValue(value val: CNValue) -> CNOval? {
		if let dict = val.toStruct() {
			return fromValue(value: dict)
		} else {
			return nil
		}
	}

	public static func fromValue(value val: CNStruct) -> CNOval? {
		if let centerval = val.value(forMember: "center"), let radval = val.value(forMember: "radius") {
			if let centerdict = centerval.toStruct(), let radius = radval.toNumber() {
				if let center = CGPoint.fromValue(value: centerdict) {
					return CNOval(center: center, radius: CGFloat(radius.floatValue))
				}
			}
		}
		return nil
	}

	public func toValue() -> CNStruct {
		let stype: CNStructType
		if let typ = CNStructTable.currentStructTable().search(byTypeName: CNOval.ClassName) {
			stype = typ
		} else {
			stype = CNStructType(typeName: "dummy")
		}
		let center = mCenter.toValue()
		let radius = NSNumber(floatLiteral: Double(mRadius))
		let values: Dictionary<String, CNValue> = [
			"center"	: .structValue(center),
			"radius"	: .numberValue(radius)
		]
		return CNStruct(type: stype, values: values)
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


