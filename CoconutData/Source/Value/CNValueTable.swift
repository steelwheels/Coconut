/**
 * @file	CNValueTable.swift
 * @brief	Define CNValueTable class
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public class CNValueTable: CNTable
{
	public static let DefaultFieldsItem	= "defaultFields"
	public static let RecordsItem		= "records"
	public static let IdItem		= "id"

	private var mPath:		CNValuePath
	private var mValueStorage:	CNValueStorage
	private var mIdentifier:	String?

	private var mDefaultFieldsCacheId:	Int
	private var mDefaultFieldsCache:  	Dictionary<String, CNValue>?
	private var mRecordValuesCacheId:	Int
	private var mRecordValuesCache:		Array<Dictionary<String, CNValue>>?

	public init(path pth: CNValuePath, valueStorage storage: CNValueStorage) {
		mPath			= pth
		mValueStorage		= storage
		mIdentifier		= ""
		mDefaultFieldsCacheId	= 0
		mDefaultFieldsCache	= nil
		mRecordValuesCacheId	= 0
		mRecordValuesCache	= nil

		/* check storage */
		if storage.value(forPath: pth) == nil {
			let msg = "No root object on storage: path=\(pth.description), storage=\(mValueStorage.description)"
			CNLog(logLevel: .error, message: msg, atFunction: #function, inFile: #file)
		}

		/* Get/set identifier */
		mIdentifier = idValue()

		/* Allocate cache */
		mDefaultFieldsCacheId = addDefaultFieldsCache()
		mRecordValuesCacheId  = addRecordValueCache()
	}

	deinit {
		mValueStorage.cache.remove(cacheId: mDefaultFieldsCacheId)
		mValueStorage.cache.remove(cacheId: mRecordValuesCacheId)
	}

	public func addDefaultFieldsCache() -> Int {
		return mValueStorage.cache.add(accessor: defaultFieldsPath())
	}

	public func addRecordValueCache() -> Int {
		return mValueStorage.cache.add(accessor: recordPath())
	}

	public var identifier: String? { get {
		return mIdentifier
	}}

	public var cache: CNTableCache { get {
		return mValueStorage.cache
	}}

	public var recordCount: Int { get {
		return recordValues().count
	}}

	public var defaultFields: Dictionary<String, CNValue> { get {
		if mValueStorage.cache.isDirty(cacheId: mDefaultFieldsCacheId) {
			let cache = allocateDefaultFields()
			mDefaultFieldsCache = cache
			mValueStorage.cache.setClean(cacheId: mDefaultFieldsCacheId)
			return cache
		} else {
			if let cache = mDefaultFieldsCache {
				return cache
			} else {
				CNLog(logLevel: .error, message: "No cache", atFunction: #function, inFile: #file)
				return [:]
			}
		}
	}}

	private func allocateDefaultFields() -> Dictionary<String, CNValue> {
		if let val = mValueStorage.value(forPath: defaultFieldsPath()) {
			if let dict = val.toDictionary() {
				return dict
			}
		}
		CNLog(logLevel: .error, message: "No \"\(CNValueTable.DefaultFieldsItem)\" property", atFunction: #function, inFile: #file)
		return [:]
	}

	public func fieldName(at index: Int) -> String? {
		let names = defaultFields.keys.sorted()
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
			return CNValueRecord(table: self, index: row)
		} else {
			return nil
		}
	}

	public func pointer(value val: CNValue, forField field: String) -> CNPointerValue? {
		guard let ident = mIdentifier else {
			CNLog(logLevel: .error, message: "The property \(CNValueTable.IdItem) is required to make value path", atFunction: #function, inFile: #file)
			return nil
		}
		let recs = search(value: val, forField: field)
		guard recs.count > 0 else {
			let valtxt = val.toText().toStrings().joined(separator: "\n")
			CNLog(logLevel: .error, message: "No matched record for \(field):\(valtxt)", atFunction: #function, inFile: #file)
			return nil
		}
		let elements: Array<CNValuePath.Element> = [
			.member(CNValueTable.RecordsItem),
			.keyAndValue(field, val)
		]
		let path = CNValuePath(identifier: ident, elements: elements)
		return CNPointerValue(path: path)
	}

	public func search(value val: CNValue, forField field: String) -> Array<CNRecord> {
		let dicts = self.recordValues()
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
		if let cached = rcd.cachedValues() {
			if !mValueStorage.append(value: .dictionaryValue(cached), forPath: recordPath()) {
				CNLog(logLevel: .error, message: "Failed to add record", atFunction: #function, inFile: #file)
			}
		}
	}

	public func append(pointer ptr: CNPointerValue) {
		guard let ident = mIdentifier else {
			CNLog(logLevel: .error, message: "The property \(CNValueTable.IdItem) is required to append pointer value", atFunction: #function, inFile: #file)
			return
		}
		let elms: Array<CNValuePath.Element> = [.member(CNValueTable.RecordsItem)]
		if !mValueStorage.append(value: .pointerValue(ptr), forPath: CNValuePath(identifier: ident, elements: elms)) {
			CNLog(logLevel: .error, message: "Failed to append pointer", atFunction: #function, inFile: #file)
		}
	}

	public func remove(at row: Int) -> Bool {
		var result = false
		if 0<=row && row<self.recordCount {
			let elmpath = CNValuePath(identifier: nil, path: recordPath(), subPath: [.index(row)])
			if mValueStorage.delete(forPath: elmpath) {
				result = true
			}
		}
		return result
	}

	public func forEach(callback cbfunc: (CNRecord) -> Void) {
		let dicts = self.recordValues()
		for i in 0..<dicts.count {
			let newrec = CNValueRecord(table: self, index: i)
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

	private func defaultFieldsPath() -> CNValuePath {
		return CNValuePath(identifier: nil, path: mPath, subPath: [.member(CNValueTable.DefaultFieldsItem)])
	}

	private func recordPath() -> CNValuePath {
		return CNValuePath(identifier: nil, path: mPath, subPath: [.member(CNValueTable.RecordsItem)])
	}

	private func idPath() -> CNValuePath {
		return CNValuePath(identifier: nil, path: mPath, subPath: [.member(CNValueTable.IdItem)])
	}

	private func recordFieldPath(index idx: Int, field fld: String) -> CNValuePath {
		return CNValuePath(identifier: nil,path: mPath, subPath: [.member(CNValueTable.RecordsItem), .index(idx), .member(fld)])
	}

	private func idValue() -> String? {
		let path = idPath()
		if let val = mValueStorage.value(forPath: path) {
			if let str = val.toString() {
				return str
			}
		}
		return nil
	}

	private func recordValues() -> Array<Dictionary<String, CNValue>> {
		if mValueStorage.cache.isDirty(cacheId: mRecordValuesCacheId) {
			let cache = allocateRecordValues()
			mRecordValuesCache = cache
			mValueStorage.cache.setClean(cacheId: mRecordValuesCacheId)
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
					} else if let ptr = elm.toPointer() {
						if let dict = pointedRecord(by: ptr) {
							result.append(dict)
						}
					} else {
						CNLog(logLevel: .error, message: "Record value must be dictionary", atFunction: #function, inFile: #file)
					}
				}
				/* Cache the current record values */
				mRecordValuesCache = result
				return result
			}
		}
		CNLog(logLevel: .error, message: "No \"\(CNValueTable.RecordsItem)\" property at \(recordPath().description)", atFunction: #function, inFile: #file)
		return []
	}

	private func pointedRecord(by ptr: CNPointerValue) -> Dictionary<String, CNValue>? {
		if let val = mValueStorage.value(forPath: ptr.path) {
			if let dict = val.toDictionary() {
				return dict
			}
		}
		return nil
	}

	public func save() -> Bool {
		return mValueStorage.save()
	}

	public func toValue() -> CNValue {
		return mValueStorage.toValue()
	}
}


