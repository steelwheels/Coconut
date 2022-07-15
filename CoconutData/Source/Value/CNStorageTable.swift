/**
 * @file	CNStorageTable.swift
 * @brief	Define CNStorageTable class
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public class CNStorageTable: CNTable
{
	public static let DefaultFieldsItem	= "defaultFields"
	public static let RecordsItem		= "records"
	public static let IdItem		= "id"

	private var mPath:		CNValuePath
	private var mStorage:		CNStorage
	private var mIdentifier:	String?

	private var mDefaultFieldsCacheId:	Int
	private var mDefaultFieldsCache:  	Dictionary<String, CNValue>?
	private var mRecordValuesCacheId:	Int
	private var mRecordValuesCache:		Array<Dictionary<String, CNValue>>?

	public init(path pth: CNValuePath, storage strg: CNStorage) {
		mPath			= pth
		mStorage		= strg
		mIdentifier		= ""
		mDefaultFieldsCacheId	= 0
		mDefaultFieldsCache	= nil
		mRecordValuesCacheId	= 0
		mRecordValuesCache	= nil

		/* check storage */
		if strg.value(forPath: pth) == nil {
			let msg = "No root object on storage: path=\(pth.description), storage=\(mStorage.description)"
			CNLog(logLevel: .error, message: msg, atFunction: #function, inFile: #file)
		}

		/* Get/set identifier */
		mIdentifier = idValue()

		/* Allocate cache */
		mDefaultFieldsCacheId = allocateDefaultFieldsCache()
		mRecordValuesCacheId  = allocateRecordValuesCache()
	}

	deinit {
		removeCache(cacheId: mDefaultFieldsCacheId)
		removeCache(cacheId: mRecordValuesCacheId)
	}

	public func allocateDefaultFieldsCache() -> Int {
		return mStorage.allocateCache(forPath: defaultFieldsPath())
	}

	public func allocateRecordValuesCache() -> Int {
		return mStorage.allocateCache(forPath: recordPath())
	}

	public func removeCache(cacheId cid: Int) {
		mStorage.removeCache(cacheId: cid)
	}

	public func isDirty(cacheId cid: Int) -> Bool {
		return mStorage.isDirty(cacheId: cid)
	}

	public func setClean(cacheId cid: Int) {
		mStorage.setClean(cacheId: cid)
	}

	public func allocateEventFunction(eventFunc efunc: @escaping CNStorage.EventFunction) -> Int {
		return mStorage.allocateEventFunction(forPath: mPath, eventFunc: efunc)
	}

	public func removeEventFunction(eventFuncId eid: Int) {
		mStorage.removeEventFunction(eventFuncId: eid)
	}

	public var identifier: String? { get {
		return mIdentifier
	}}

	public var recordCount: Int { get {
		return recordValues().count
	}}

	public var defaultFields: Dictionary<String, CNValue> { get {
		if isDirty(cacheId: mDefaultFieldsCacheId) {
			let cache = allocateDefaultFields()
			mDefaultFieldsCache = cache
			setClean(cacheId: mDefaultFieldsCacheId)
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
		if let val = mStorage.value(forPath: defaultFieldsPath()) {
			if let dict = val.toDictionary() {
				return dict
			}
		}
		CNLog(logLevel: .error, message: "No \"\(CNStorageTable.DefaultFieldsItem)\" property", atFunction: #function, inFile: #file)
		return [:]
	}

	public var fieldNames: Array<String> { get {
		return Array(defaultFields.keys)
	}}

	public func fieldName(at index: Int) -> String? {
		let names = defaultFields.keys.sorted()
		if 0<=index && index<names.count {
			return names[index]
		} else {
			return nil
		}
	}

	public func newRecord() -> CNRecord {
		return CNStorageRecord(defaultFields: self.defaultFields)
	}

	public func record(at row: Int) -> CNRecord? {
		let recvals = self.recordValues()
		let cnt = recvals.count
		if 0<=row && row<cnt {
			return CNStorageRecord(table: self, index: row)
		} else {
			return nil
		}
	}

	public func append(record rcd: CNRecord) {
		if rcd.index != nil {
			CNLog(logLevel: .error, message: "The record has already index")
			return
		}
		if let cached = rcd.cachedValues() {
			if !mStorage.append(value: .dictionaryValue(cached), forPath: recordPath()) {
				CNLog(logLevel: .error, message: "Failed to add record", atFunction: #function, inFile: #file)
			}
		}
	}

	public func append(pointer ptr: CNPointerValue) {
		guard let ident = mIdentifier else {
			CNLog(logLevel: .error, message: "The property \(CNStorageTable.IdItem) is required to append pointer value", atFunction: #function, inFile: #file)
			return
		}
		let elms: Array<CNValuePath.Element> = [.member(CNStorageTable.RecordsItem)]
		if !mStorage.append(value: .pointerValue(ptr), forPath: CNValuePath(identifier: ident, elements: elms)) {
			CNLog(logLevel: .error, message: "Failed to append pointer", atFunction: #function, inFile: #file)
		}
	}

	public func remove(at row: Int) -> Bool {
		var result = false
		if 0<=row && row<self.recordCount {
			let elmpath = CNValuePath(path: recordPath(), subPath: [.index(row)])
			if mStorage.delete(forPath: elmpath) {
				result = true
			}
		}
		return result
	}

	public func pointer(value val: CNValue, forField field: String) -> CNPointerValue? {
		guard let ident = mIdentifier else {
			CNLog(logLevel: .error, message: "The property \(CNStorageTable.IdItem) is required to make value path", atFunction: #function, inFile: #file)
			return nil
		}
		let recs = search(value: val, forField: field)
		guard recs.count > 0 else {
			let valtxt = val.toText().toStrings().joined(separator: "\n")
			CNLog(logLevel: .error, message: "No matched record for \(field):\(valtxt)", atFunction: #function, inFile: #file)
			return nil
		}
		let elements: Array<CNValuePath.Element> = [
			.member(CNStorageTable.RecordsItem),
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
					let newrec = CNStorageRecord(table: self, index: i)
					result.append(newrec)
				case .orderedAscending, .orderedDescending:
					break
				}
			}
		}
		return result
	}

	public func forEach(callback cbfunc: (CNRecord) -> Void) {
		let dicts = self.recordValues()
		for i in 0..<dicts.count {
			let newrec = CNStorageRecord(table: self, index: i)
			cbfunc(newrec)
		}
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
		if mStorage.set(value: val, forPath: recpath) {
			return true
		} else {
			return false
		}
	}

	private func defaultFieldsPath() -> CNValuePath {
		return CNValuePath(path: mPath, subPath: [.member(CNStorageTable.DefaultFieldsItem)])
	}

	private func recordPath() -> CNValuePath {
		return CNValuePath(path: mPath, subPath: [.member(CNStorageTable.RecordsItem)])
	}

	private func idPath() -> CNValuePath {
		return CNValuePath(path: mPath, subPath: [.member(CNStorageTable.IdItem)])
	}

	private func recordFieldPath(index idx: Int, field fld: String) -> CNValuePath {
		return CNValuePath(path: mPath, subPath: [.member(CNStorageTable.RecordsItem), .index(idx), .member(fld)])
	}

	private func idValue() -> String? {
		let path = idPath()
		if let val = mStorage.value(forPath: path) {
			if let str = val.toString() {
				return str
			}
		}
		return nil
	}

	private func recordValues() -> Array<Dictionary<String, CNValue>> {
		if mStorage.isDirty(cacheId: mRecordValuesCacheId) {
			let cache = allocateRecordValues()
			mRecordValuesCache = cache
			setClean(cacheId: mRecordValuesCacheId)
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
		if let val = mStorage.value(forPath: recordPath()) {
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
		CNLog(logLevel: .error, message: "No \"\(CNStorageTable.RecordsItem)\" property at \(recordPath().description)", atFunction: #function, inFile: #file)
		return []
	}

	private func pointedRecord(by ptr: CNPointerValue) -> Dictionary<String, CNValue>? {
		if let val = mStorage.value(forPath: ptr.path) {
			if let dict = val.toDictionary() {
				return dict
			}
		}
		return nil
	}

	public func save() -> Bool {
		return mStorage.save()
	}

	public func toValue() -> CNValue {
		return mStorage.toValue()
	}
}


