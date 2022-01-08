/**
 * @file	CNTable.swift
 * @brief	Define CNTable protocol
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public protocol CNRecord
{
	var fieldCount: Int { get }
	var fieldNames: Array<String> { get }

	func value(ofField name: String) -> CNValue?
	func setValue(value val: CNValue, forField name: String) -> Bool
}

public enum CNTableLoadResult {
	case ok
	case error(NSError)
}

public protocol CNTable
{
	var recordCount: Int { get }
	var allFieldNames:    Array<String> { get }
	var activeFieldNames: Array<String> { get set }

	func newRecord() -> CNRecord
	func record(at row: Int) -> CNRecord?
	func append(record rcd: CNRecord)
	func forEach(callback cbfunc: (_ record: CNRecord) -> Void)

	func sort(byDescriptors descs: CNSortDescriptors)
}

extension CNRecord
{
	public func compare(forField name: String, with rec: CNRecord) -> ComparisonResult {
		let s0 = self.value(ofField: name) ?? .nullValue
		let s1 = rec.value(ofField: name)  ?? .nullValue
		return CNCompareValue(nativeValue0: s0, nativeValue1: s1)
	}
}


