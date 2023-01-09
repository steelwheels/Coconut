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
	public static let InterfaceName = "OvalIF"

	private var mCenter:	CGPoint
	private var mRadius:	CGFloat

	static func allocateInterfaceType(pointIF ptif: CNInterfaceType) -> CNInterfaceType {
		let ptypes: Dictionary<String, CNValueType> = [
			"center":	.interfaceType(ptif),
			"radius":	.numberType
		]
		return CNInterfaceType(name: InterfaceName, base: nil, types: ptypes)
	}

	public init(center ctr: CGPoint, radius rad: CGFloat){
		mCenter		= ctr
		mRadius		= rad
	}

	public static func fromValue(value val: CNInterfaceValue) -> CNOval? {
		guard val.type.name == InterfaceName else {
			return nil
		}
		if let centerval = val.get(name: "center"), let radval = val.get(name: "radius") {
			if let centerif = centerval.toInterface(interfaceName: CGPoint.InterfaceName),
			   let radius = radval.toNumber() {
				if let center = CGPoint.fromValue(value: centerif) {
					return CNOval(center: center, radius: CGFloat(radius.floatValue))
				}
			}
		}
		return nil
	}

	public func toValue() -> CNInterfaceValue {
		let iftype = thisIfType()
		let center = mCenter.toValue()
		let radius = NSNumber(floatLiteral: Double(mRadius))
		let ptypes: Dictionary<String, CNValue> = [
			"center"	: .interfaceValue(center),
			"radius"	: .numberValue(radius)
		]
		return CNInterfaceValue(types: iftype, values: ptypes)
	}

	private func thisIfType() -> CNInterfaceType {
		let iftype: CNInterfaceType
		if let typ = CNInterfaceTable.currentInterfaceTable().search(byTypeName: CNOval.InterfaceName) {
			iftype = typ
		} else {
			CNLog(logLevel: .error, message: "No interface type: \"\(CNOval.InterfaceName)\"",
			      atFunction: #function, inFile: #file)
			iftype = CNInterfaceType.nilType
		}
		return iftype
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


