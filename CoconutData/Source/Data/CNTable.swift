/**
 * @file	CNTable.swift
 * @brief	Define CNTable protocol
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public enum CNTableLoadResult {
	case ok
	case error(NSError)
}

public protocol CNTableCache
{
	func remove(cacheId cid: Int)
	func isDirty(cacheId cid: Int) -> Bool
	func setClean(cacheId cid: Int)
}

public protocol CNTable
{
	func addColumnNameCache() -> Int
	func addRecordValueCache() -> Int
	var cache: CNTableCache { get }

	var identifier: String? { get }
	var recordCount: Int { get }

	var allFieldNames:    Array<String> { get }
	func fieldName(at index: Int) -> String?

	func record(at row: Int) -> CNRecord?
	func pointer(value val: CNValue, forField field: String) -> CNPointerValue?

	func search(value val: CNValue, forField field: String) -> Array<CNRecord>
	func append(record rcd: CNRecord)
	func append(pointer ptr: CNPointerValue)
	func remove(at row: Int) -> Bool
	func save() -> Bool

	func forEach(callback cbfunc: (_ record: CNRecord) -> Void)

	func sort(byDescriptors descs: CNSortDescriptors)
	func toValue() -> CNValue
}

