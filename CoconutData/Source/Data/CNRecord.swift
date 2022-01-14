/**
 * @file	CNRecord.swift
 * @brief	Define CNRecord protocol
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public protocol CNRecord
{
	var fieldCount: Int { get }
	var fieldNames: Array<String> { get }

	func value(ofField name: String) -> CNValue?
	func setValue(value val: CNValue, forField name: String) -> Bool
}

extension CNRecord
{
	public func compare(forField name: String, with rec: CNRecord) -> ComparisonResult {
		let s0 = self.value(ofField: name) ?? .nullValue
		let s1 = rec.value(ofField: name)  ?? .nullValue
		return CNCompareValue(nativeValue0: s0, nativeValue1: s1)
	}
}

