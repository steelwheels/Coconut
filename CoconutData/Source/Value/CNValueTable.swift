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
		/* Allocate cache */
		storage.cache.add(accessor: mPath)
	}

	deinit {
		mValueStorage.cache.remove(accessor: mPath)
	}

	public var recordCount: Int { get {
		return recordValues().count
	}}

	public var allFieldNames: Array<String> { get {
		if mValueStorage.cache.isDirty(accessor: mPath) {
			let cache = allocateAllFieldNames()
			mColumnNamesCache = cache
			return cache
		} else {
			if let cache = mColumnNamesCache {
				return cache
			} else {
				CNLog(logLevel: .error, message: "No cache", atFunction: #function, inFile: #file)
				return []
			}
		}
	}}

	private func allocateAllFieldNames() -> Array<String> {
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
				return result
			}
		}
		CNLog(logLevel: .error, message: "No \"\(CNValueTable.ColumnNamesItem)\" property", atFunction: #function, inFile: #file)
		return []
	}

	public func fieldName(at index: Int) -> String? {
		let names = self.allFieldNames
		if 0<=index && index<names.count {
			return names[index]
		} else {
			return nil
		}
	}

	public func record(at row: Int) -> CNRecord? {
		let recvals = self.recordValues()
		let cnt = recvals.count
		if 0<=row && row<cnt {
			return CNRecord(table: self, index: row)
		} else {
			return nil
		}
	}

	public func search(value val: CNValue, forField field: String) -> Array<CNRecord> {
		let dicts = self.recordValues()
		var result: Array<CNRecord> = []
		let count = dicts.count
		for i in 0..<count {
			if let dval = dicts[i][field] {
				switch CNCompareValue(nativeValue0: dval, nativeValue1: val) {
				case .orderedSame:
					let newrec = CNRecord(table: self, index: i)
					result.append(newrec)
				case .orderedAscending, .orderedDescending:
					break
				}
			}
		}
		return result
	}

	public func append(record rcd: CNRecord) {
		/* Append the contents of record */
		var contents : Dictionary<String, CNValue> = [:]
		let fields = rcd.fieldNames
		for field in fields {
			if let val = rcd.value(ofField: field) {
				contents[field] = val
			}
		}
		if !mValueStorage.append(value: .dictionaryValue(contents), forPath: recordPath()) {
			CNLog(logLevel: .error, message: "Failed to add record", atFunction: #function, inFile: #file)
		}
	}

	public func remove(at row: Int) -> Bool {
		var result = false
		if 0<=row && row<self.recordCount {
			let elmpath = CNValuePath(path: recordPath(), subPath: [.index(row)])
			if mValueStorage.delete(forPath: elmpath) {
				result = true
			}
		}
		/* Clear cache */
		mRecordValuesCache = nil
		return result
	}

	public func forEach(callback cbfunc: (CNRecord) -> Void) {
		let dicts = self.recordValues()
		for i in 0..<dicts.count {
			let newrec = CNRecord(table: self, index: i)
			cbfunc(newrec)
		}
	}

	public func sort(byDescriptors descs: CNSortDescriptors) {
		CNLog(logLevel: .error, message: "Not supported", atFunction: #function, inFile: #file)
	}

	public func getRecordValue(index idx: Int, field fld: String) -> CNValue? {
		let recs = self.recordValues()
		if 0<=idx && idx<recs.count {
			return recs[idx][fld]
		} else {
			return nil
		}
	}

	public func setRecordValue(_ val: CNValue, index idx: Int, field fld: String) -> Bool {
		let recpath = recordFieldPath(index: idx, field: fld)
		if mValueStorage.set(value: val, forPath: recpath) {
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

	public func recordValues() -> Array<Dictionary<String, CNValue>> {
		if mValueStorage.cache.isDirty(accessor: mPath) {
			let cache = allocateRecordValues()
			mRecordValuesCache = cache
			return cache
		} else {
			if let cache = mRecordValuesCache {
				return cache
			} else {
				CNLog(logLevel: .error, message: "No cache", atFunction: #function, inFile: #file)
				return []
			}
		}
	}

	private func allocateRecordValues() -> Array<Dictionary<String, CNValue>> {
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
		return []
	}

	public func save() -> Bool {
		return mValueStorage.save()
	}

	public func toValue() -> CNValue {
		return mValueStorage.toValue()
	}
}


