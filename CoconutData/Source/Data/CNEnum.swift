/**
 * @file	CNEnum.swift
 * @brief	Define CNEnum class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public struct CNEnum {
	public static let ClassName		= "enum"

	public var name: 	String
	public var value:	Int

	public init(name n: String, value v: Int){
		name 	= n
		value	= v
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNEnum? {
		if let nameval = val["name"], let valval = val["value"] {
			if let namestr = nameval.toString(), let valnum = valval.toNumber() {
				return CNEnum(name: namestr, value: valnum.intValue)
			}
		}
		return nil
	}

	public func toValue() -> Dictionary<String, CNValue> {
		let result: Dictionary<String, CNValue> = [
			"class":	.stringValue(CNEnum.ClassName),
			"name":		.stringValue(self.name),
			"value":	.numberValue(NSNumber(integerLiteral: Int(self.value)))
		]
		return result
	}

}

public class CNEnumType
{
	public static let ClassName		= "enumType"

	private var mTypeName:		String
	private var mMembers:		Array<CNEnum>

	public var typeName: String        { get { return mTypeName }}
	public var members:  Array<CNEnum> { get { return mMembers  }}

	public init(typeName name: String){
		mTypeName  = name
		mMembers   = []
	}

	public func add(member memb: CNEnum){
		mMembers.append(memb)
	}

	public func add(name nm: String, value val: Int){
		let newobj = CNEnum(name: nm, value: val)
		mMembers.append(newobj)
	}

	public func add(members membs: Dictionary<String, Int>){
		for key in membs.keys {
			if let val = membs[key] {
				self.add(name: key, value: val)
			}
		}
	}

	public func search(byName name: String) -> CNEnum? {
		for memb in mMembers {
			if memb.name == name {
				return memb
			}
		}
		return nil
	}
}
