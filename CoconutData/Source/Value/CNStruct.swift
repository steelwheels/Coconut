/*
 * @file	CNStruct.swift
 * @brief	Define CNStruct class
 * @par Copyright
 *   Copyright (C) 2019, 2021 Steel Wheels Project
 */

import Foundation

open class CNStruct
{
	private var mStructName:	String
	private var mMembers:		Dictionary<String, CNValue>

	public init(name nm: String){
		mStructName = nm
		mMembers    = [:]
	}

	public var structName: String { return mStructName }
	public var members: Dictionary<String, CNValue> { return mMembers }

	public func member(name nm: String) -> CNValue? {
		return mMembers[nm]
	}

	public func setMember(name nm: String, value val: CNValue){
		mMembers[nm] = val
	}

	public func toValue() -> CNValue {
		var result: Dictionary<String, CNValue> = [:]
		for name in mMembers.keys {
			result[name] = mMembers[name]
		}
		return CNValue.dictionaryValue(result)
	}
}

