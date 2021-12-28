/**
 * @file	CNEnum.swift
 * @brief	Define CNEnum class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public struct CNEnum {
	public static let ClassName		= "enum"

	public var type: 	String
	public var value:	Int

	public init(type t: String, value v: Int){
		type 	= t
		value	= v
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNEnum? {
		if let typeval = val["type"], let valval = val["value"] {
			if let typestr = typeval.toString(), let valnum = valval.toNumber() {
				return CNEnum(type: typestr, value: valnum.intValue)
			}
		}
		return nil
	}

	public func toValue() -> Dictionary<String, CNValue> {
		let result: Dictionary<String, CNValue> = [
			"class":	.stringValue(CNEnum.ClassName),
			"type":		.stringValue(self.type),
			"value":	.numberValue(NSNumber(integerLiteral: self.value))
		]
		return result
	}

}
