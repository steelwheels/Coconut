/**
 * @file	CNValueRecord.swift
 * @brief	Define CNValueTable class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNValueRecord: CNRecord
{
	private var mValues:	Dictionary<String, CNValue>

	public init(){
		mValues		= [:]
	}

	public var fieldCount: Int { get {
		return mValues.count
	}}

	public var fieldNames: Array<String> { get {
		return Array(mValues.keys.sorted())
	}}

	public func value(ofField name: String) -> CNValue? {
		return mValues[name]
	}

	public func setValue(value val: CNValue, forField name: String) -> Bool {
		mValues[name] = val
		return true
	}

	public func toValue() -> CNValue {
		return .dictionaryValue(mValues)
	}
}

