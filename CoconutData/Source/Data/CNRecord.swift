/**
 * @file	CNRecord.swift
 * @brief	Define CNRecord protocol
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public protocol CNRecord
{
	var fieldCount: Int		{ get }
	var fieldNames: Array<String>	{ get }
	var index: Int?			{ get }

	func value(ofField name: String) -> CNValue?
	func setValue(value val: CNValue, forField name: String) -> Bool
	func cachedValues() -> Dictionary<String, CNValue>?

	func toValue() -> Dictionary<String, CNValue>

	func compare(forField name: String, with rec: CNRecord) -> ComparisonResult
}

public extension CNRecord
{
	var description: String { get {
		let val: CNValue = .dictionaryValue(self.toValue())
		return val.toText().toStrings().joined(separator: "\n")
	}}
}
