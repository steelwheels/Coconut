/**
 * @file	CNTable.swift
 * @brief	Define CNTable protocol
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public enum CNTableLoadResult {
	case ok
	case error(NSError)
}

public protocol CNTable
{
	var recordCount: Int { get }

	var allFieldNames:    Array<String> { get }

	func newRecord() -> CNRecord
	func record(at row: Int) -> CNRecord?
	func search(value val: CNValue, forField field: String) -> Array<CNRecord>
	func append(record rcd: CNRecord)
	func forEach(callback cbfunc: (_ record: CNRecord) -> Void)

	func sort(byDescriptors descs: CNSortDescriptors)
}


