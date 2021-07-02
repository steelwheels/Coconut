/**
 * @file	CNRecord.swift
 * @brief	Define CNRecord class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public protocol CNRecord
{
	var itemCount: Int { get }

	func value(forName name: String) -> CNNativeValue?
	func setValue(value val: CNNativeValue, byName name: String)
}

public class CNNativeValueRecord: CNRecord
{
	private var mTable: Dictionary<String, CNNativeValue>

	public init(){
		mTable = [:]
	}

	public var itemCount: Int {
		get { return mTable.count }
	}

	public func value(forName name: String) -> CNNativeValue? {
		return mTable[name]
	}

	public func setValue(value val: CNNativeValue, byName name: String) {
		mTable[name] = val
	}
}
