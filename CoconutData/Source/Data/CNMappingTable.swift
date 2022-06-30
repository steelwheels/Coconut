/**
 * @file	CNMappingTable.swift
 * @brief	Define CNMappingTable class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public protocol CNMappingTableProtocol
{
	typealias VirtualFieldCallback = (_ rec: CNRecord) -> CNValue	// (field-name, row-index) -> Value
	typealias FilterFunction       = (_ rec: CNRecord) -> Bool
	typealias CompareFunction      = (_ rec0: CNRecord, _ rec1: CNRecord) -> ComparisonResult

	func setFilter(filterFunction mfunc: @escaping FilterFunction)
	func addVirtualField(name field: String, callbackFunction cbfunc: @escaping VirtualFieldCallback)

	var sortOrder: CNSortOrder? { get set }
	func set(compareFunction comp: @escaping CompareFunction)
}

public class CNMappingTable: CNTable, CNMappingTableProtocol
{
	private var mSourceTable:		CNTable
	private var mCacheId:			Int
	private var mRecords:			Array<CNRecord>
	private var mRecordIndexes:		Array<Int>
	private var mFilterFunc:		FilterFunction?
	private var mCompareFunc:		CompareFunction?
	private var mSortType:			CNSortOrder?
	private var mVirtualFieldCallbacks:	Dictionary<String, VirtualFieldCallback>
	private var mDoReload:			Bool

	public init(sourceTable table: CNTable){
		mSourceTable 		= table
		mCacheId     		= table.addRecordValueCache()
		mRecords		= []
		mRecordIndexes		= []
		mFilterFunc		= nil
		mCompareFunc		= nil
		mSortType		= nil
		mVirtualFieldCallbacks	= [:]
		mDoReload		= false
	}

	deinit {
		mSourceTable.cache.remove(cacheId: mCacheId)
	}

	public func setFilter(filterFunction mfunc: @escaping FilterFunction){
		mFilterFunc = mfunc
	}

	public func addDefaultFieldsCache() -> Int {
		return mSourceTable.addDefaultFieldsCache()
	}

	public func addRecordValueCache() -> Int {
		return mSourceTable.addRecordValueCache()
	}

	public var identifier: String? { get {
		return mSourceTable.identifier
	}}

	public var cache: CNTableCache { get {
		return mSourceTable.cache
	}}

	public var recordCount: Int { get {
		let recs = getRecords()
		return recs.count
	}}

	public var defaultFields: Dictionary<String, CNValue> { get {
		var fields = mSourceTable.defaultFields
		for vkey in mVirtualFieldCallbacks {
			fields[vkey.key] = .nullValue
		}
		return fields
	}}

	public func fieldName(at index: Int) -> String? {
		return mSourceTable.fieldName(at: index)
	}

	public func addVirtualField(name field: String, callbackFunction cbfunc: @escaping VirtualFieldCallback) {
		mVirtualFieldCallbacks[field] = cbfunc
	}

	public func mergeVirtualFields(callbacks cbfuncs: Dictionary<String, VirtualFieldCallback>) {
		for (key, val) in cbfuncs {
			mVirtualFieldCallbacks[key] = val
		}
	}

	public var sortOrder: CNSortOrder? {
		get         { return mSortType }
		set(newval) { mSortType = newval ; mDoReload = true }
	}

	public func set(compareFunction comp: @escaping CompareFunction) {
		mCompareFunc	= comp ; mDoReload = true
	}

	public func newRecord() -> CNRecord {
		return mSourceTable.newRecord()
	}

	public func record(at row: Int) -> CNRecord? {
		let recs = getRecords()
		if 0<=row && row<recs.count {
			return recs[row]
		} else {
			return nil
		}
	}

	public func pointer(value val: CNValue, forField field: String) -> CNPointerValue? {
		guard let ident = mSourceTable.identifier else {
			CNLog(logLevel: .error, message: "The property \"\(CNStorageTable.IdItem)\" is required to make value path", atFunction: #function, inFile: #file)
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
		var result: Array<CNRecord> = []
		let recs = getRecords()
		for rec in recs {
			if let rval = rec.value(ofField: field) {
				if CNIsSameValue(nativeValue0: rval, nativeValue1: val) {
					result.append(rec)
				}
			}
		}
		return result
	}

	public func append(record rcd: CNRecord) {
		mSourceTable.append(record: rcd)
	}

	public func append(pointer ptr: CNPointerValue) {
		mSourceTable.append(pointer: ptr)
	}

	public func remove(at row: Int) -> Bool {
		if 0<=row && row<mRecordIndexes.count {
			let idx = mRecordIndexes[row]
			return mSourceTable.remove(at: idx)
		} else {
			CNLog(logLevel: .error, message: "Invalid index cache", atFunction: #function, inFile: #file)
			return false
		}
	}

	public func save() -> Bool {
		return mSourceTable.save()
	}

	public func forEach(callback cbfunc: (CNRecord) -> Void) {
		let recs = getRecords()
		for rec in recs {
			cbfunc(rec)
		}
	}

	public func toValue() -> CNValue {
		return mSourceTable.toValue()
	}

	private func getRecords() -> Array<CNRecord> {
		let filterfunc = mFilterFunc ?? { (_ rec: CNRecord) -> Bool in return true }
		if mDoReload || mSourceTable.cache.isDirty(cacheId: mCacheId) {
			mRecords       = []
			mRecordIndexes = []
			for i in 0..<mSourceTable.recordCount {
				if let rec = mSourceTable.record(at: i) {
					let newrec = CNMappingRecord(sourceRecord: rec, virtualFields: mVirtualFieldCallbacks)
					if filterfunc(newrec){
						addRecord(records: &mRecords, indices: &mRecordIndexes, newRecord: newrec, newIndex: i)
					}
				}
			}
			mSourceTable.cache.setClean(cacheId: mCacheId)
			mDoReload = false
		}
		return mRecords
	}

	private func addRecord(records recs: inout Array<CNRecord>, indices idxs: inout Array<Int>, newRecord newrec: CNRecord, newIndex newidx: Int) {
		if let stype = mSortType {
			switch stype {
			case .increasing:
				guard let compfunc = mCompareFunc else {
					recs.append(newrec)
					idxs.append(newidx)
					CNLog(logLevel: .error, message: "No callback to sort", atFunction: #function, inFile: #file)
					return
				}
				var added = false
				loop: for i in 0..<recs.count {
					switch compfunc(newrec, recs[i]) {
					case .orderedAscending, .orderedSame:
						recs.insert(newrec, at: i)
						idxs.insert(newidx, at: i)
						added = true
						break loop
					case .orderedDescending:
						break
					}
				}
				if !added {
					recs.append(newrec)
					idxs.append(newidx)
				}
			case .decreasing:
				guard let compfunc = mCompareFunc else {
					recs.append(newrec)
					idxs.append(newidx)
					CNLog(logLevel: .error, message: "No callback to sort", atFunction: #function, inFile: #file)
					return
				}
				var added = false
				loop: for i in 0..<recs.count {
					switch compfunc(newrec, recs[i]) {
					case .orderedDescending, .orderedSame:
						recs.insert(newrec, at: i)
						idxs.insert(newidx, at: i)
						added = true
						break loop
					case .orderedAscending:
						break
					}
				}
				if !added {
					recs.append(newrec)
					idxs.append(newidx)
				}
			}
		} else {
			/* Needless to sort */
			recs.append(newrec)
			idxs.append(newidx)
		}
	}
}
