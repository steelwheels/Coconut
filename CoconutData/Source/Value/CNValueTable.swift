/**
 * @file	CNValueTable.swift
 * @brief	Define CNValueTable class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNValueTable: CNTable
{
	private static let ColumnNamesItem	= "columnNames"
	private static let RecordsItem		= "records"

	private var mPath:		CNValuePath
	private var mValueStorage:	CNValueStorage

	private var mColumnNamesCache:  Array<String>?
	private var mRecordValuesCache:	Array<Dictionary<String, CNValue>>?

	public init(path pth: CNValuePath, valueStorage storage: CNValueStorage) {
		mPath			= pth
		mValueStorage		= storage
		mColumnNamesCache	= nil
		mRecordValuesCache	= nil

		/* check storage */
		if storage.value(forPath: pth) == nil {
			let msg = "No root object on storage: path=\(pth.description), storage=\(mValueStorage.description)"
			CNLog(logLevel: .error, message: msg, atFunction: #function, inFile: #file)
		}
	}

	public var recordCount: Int { get {
		if let recs = recordValues() {
			return recs.count
		} else {
			return 0
		}
	}}

	public var allFieldNames: Array<String> { get {
		if let cache = mColumnNamesCache {
			return cache
		}
		if let val = mValueStorage.value(forPath: columnNamesPath()) {
			if let arr = val.toArray() {
				var result: Array<String> = []
				for elm in arr {
					if let str = elm.toString() {
						result.append(str)
					} else {
						CNLog(logLevel: .error, message: "Column name must be string", atFunction: #function, inFile: #file)
					}
				}
				mColumnNamesCache = result
				return result
			}
		}
		CNLog(logLevel: .error, message: "No \"\(CNValueTable.ColumnNamesItem)\" property", atFunction: #function, inFile: #file)
		return []
	}}

	public func newRecord() -> CNRecord {
		let newrec = CNValueRecord(table: self, index: self.recordCount)
		let empty: Dictionary<String, CNValue> = [:]
		if !mValueStorage.append(value: .dictionaryValue(empty), forPath: recordPath()) {
			CNLog(logLevel: .error, message: "Failed to add record", atFunction: #function, inFile: #file)
		}
		/* Clear cache */
		mRecordValuesCache = nil
		return newrec
	}

	public func record(at row: Int) -> CNRecord? {
		if let recvals = self.recordValues() {
			let cnt = recvals.count
			if 0<=row && row<cnt {
				return CNValueRecord(table: self, index: row)
			}
		}
		return nil
	}

	public func search(value val: CNValue, forField field: String) -> Array<CNRecord> {
		guard let dicts = self.recordValues() else {
			return []
		}
		var result: Array<CNRecord> = []
		let count = dicts.count
		for i in 0..<count {
			if let dval = dicts[i][field] {
				switch CNCompareValue(nativeValue0: dval, nativeValue1: val) {
				case .orderedSame:
					let newrec = CNValueRecord(table: self, index: i)
					result.append(newrec)
				case .orderedAscending, .orderedDescending:
					break
				}
			}
		}
		return result
	}

	public func append(record rcd: CNRecord) {
		// Nothing have to do (Already added at newRecord())
	}

	public func forEach(callback cbfunc: (CNRecord) -> Void) {
		if let dicts = self.recordValues() {
			for i in 0..<dicts.count {
				let newrec = CNValueRecord(table: self, index: i)
				cbfunc(newrec)
			}
		} else {
			/* Failed to execute */
			CNLog(logLevel: .error, message: "Failed to execute forEach", atFunction: #function, inFile: #file)
		}
	}

	public func sort(byDescriptors descs: CNSortDescriptors) {
		CNLog(logLevel: .error, message: "Not supported", atFunction: #function, inFile: #file)
	}

	public func setRecordValue(_ val: CNValue, index idx: Int, field fld: String) -> Bool {
		let recpath = recordFieldPath(index: idx, field: fld)
		if mValueStorage.set(value: val, forPath: recpath) {
			mRecordValuesCache = nil
			return true
		} else {
			return false
		}
	}

	private func columnNamesPath() -> CNValuePath {
		return CNValuePath(path: mPath, subPath: [.member(CNValueTable.ColumnNamesItem)])
	}

	private func recordPath() -> CNValuePath {
		return CNValuePath(path: mPath, subPath: [.member(CNValueTable.RecordsItem)])
	}

	private func recordFieldPath(index idx: Int, field fld: String) -> CNValuePath {
		return CNValuePath(path: mPath, subPath: [.member(CNValueTable.RecordsItem), .index(idx), .member(fld)])
	}

	public func recordValues() -> Array<Dictionary<String, CNValue>>? {
		if let cache = mRecordValuesCache {
			return cache
		}
		if let val = mValueStorage.value(forPath: recordPath()) {
			if let arr = val.toArray() {
				var result: Array<Dictionary<String, CNValue>> = []
				for elm in arr {
					if let dict = elm.toDictionary() {
						result.append(dict)
					} else {
						CNLog(logLevel: .error, message: "Record value must be dictionary", atFunction: #function, inFile: #file)
					}
				}
				/* Cache the current record values */
				mRecordValuesCache = result
				return result
			}
		}
		CNLog(logLevel: .error, message: "Invalid \"\(CNValueTable.RecordsItem)\" property", atFunction: #function, inFile: #file)
		return nil
	}
}


