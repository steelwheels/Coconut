/*
 * @file	CNNativeStruct.swift
 * @brief	Define CNNativeStruct class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

open class CNNativeStruct
{
	private var mStructName:	String
	private var mMembers:		Dictionary<String, CNNativeValue>

	public init(name nm: String){
		mStructName = nm
		mMembers    = [:]
	}

	public var structName: String { return mStructName }
	public var members: Dictionary<String, CNNativeValue> { return mMembers }

	public func member(name nm: String) -> CNNativeValue? {
		return mMembers[nm]
	}

	public func setMember(name nm: String, value val: CNNativeValue){
		mMembers[nm] = val
	}

	public func toValue() -> CNNativeValue {
		var result: Dictionary<String, CNNativeValue> = [:]
		for name in mMembers.keys {
			result[name] = mMembers[name]
		}
		return CNNativeValue.dictionaryValue(result)
	}
}

