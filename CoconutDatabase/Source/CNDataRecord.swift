/**
 * @file	CNDataRecord.swift
 * @brief	Define CNDataRecord class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public protocol CNDataRecord
{
	var itemCount: Int { get }

	func value(ofField name: String) -> CNNativeValue?
	func setValue(value val: CNNativeValue, forField name: String) -> Bool
}

public class CNNativeValueRecord: CNDataRecord
{
	private var mTable: Dictionary<String, CNNativeValue>

	public init(){
		mTable = [:]
	}

	public var itemCount: Int {
		get { return mTable.count }
	}

	public func value(ofField name: String) -> CNNativeValue? {
		return mTable[name]
	}

	public func setValue(value val: CNNativeValue, forField name: String) -> Bool {
		mTable[name] = val
		return true
	}
}
