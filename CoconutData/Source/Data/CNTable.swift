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

	var isDirty: Bool { get }
	func save()
}

public enum CNTableLoadResult {
	case ok
	case error(NSError)
}

public protocol CNTable
{
	var recordCount: Int { get }
	var fieldNames: Array<String> { get }

	func load(fromURL url: URL?) -> CNTableLoadResult

	func newRecord() -> CNRecord
	func record(at row: Int) -> CNRecord?
	func append(record rcd: CNRecord)
	func forEach(callback cbfunc: (_ record: CNRecord) -> Void)

	func sort(byDescriptors descs: CNSortDescriptors)
	func save()
}

extension CNRecord
{
	public func compare(forField name: String, with rec: CNRecord) -> ComparisonResult {
		let s0 = self.value(ofField: name) ?? .nullValue
		let s1 = rec.value(ofField: name)  ?? .nullValue
		return CNCompareValue(nativeValue0: s0, nativeValue1: s1)
	}
}

extension CNTable
{
	public var isDirty: Bool { get {
		var result = false
		for i in 0..<self.recordCount {
			if let rec = self.record(at: i) {
				if rec.isDirty {
					result = true
					break
				}
			}
		}
		return result
	}}

	public func toValue() -> CNValue {
		var result: Array<CNValue> = []
		self.forEach(callback: {
			(_ record: CNRecord) -> Void in
			if let rec = record as? CNValueRecord {
				result.append(rec.toValue())
			}
		})
		return .arrayValue(result)
	}
}

