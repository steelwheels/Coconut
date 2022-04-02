/**
 * @file	CNMappingTable.swift
 * @brief	Define CNMappingTable class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNMappingTable: CNTable
{
	public typealias FilterFunction = (_ rec: CNRecord) -> Bool

	private var mSourceTable:	CNTable
	private var mCacheId:		Int
	private var mRecords:		Array<CNRecord>
	private var mRecordIndexes:	Array<Int>
	private var mFilterFunc:	FilterFunction?

	public init(sourceTable table: CNTable){
		mSourceTable 	= table
		mCacheId     	= table.addRecordValueCache()
		mRecords	= []
		mRecordIndexes	= []
		mFilterFunc	= nil
	}

	deinit {
		mSourceTable.cache.remove(cacheId: mCacheId)
	}

	public func setFilter(filterFunction mfunc: @escaping FilterFunction){
		mFilterFunc = mfunc
	}

	public func addColumnNameCache() -> Int {
		return mSourceTable.addColumnNameCache()
	}

	public func addRecordValueCache() -> Int {
		return mSourceTable.addRecordValueCache()
	}

	public var cache: CNTableCache { get {
		return mSourceTable.cache
	}}

	public var recordCount: Int { get {
		let recs = getRecords()
		return recs.count
	}}

	public var allFieldNames: Array<String> { get {
		return mSourceTable.allFieldNames
	}}

	public func fieldName(at index: Int) -> String? {
		return mSourceTable.fieldName(at: index)
	}

	public func record(at row: Int) -> CNRecord? {
		let recs = getRecords()
		if 0<=row && row<recs.count {
			return recs[row]
		} else {
			return nil
		}
	}

	public func search(value val: CNValue, forField field: String) -> Array<CNRecord> {
		var result: Array<CNRecord> = []
		let recs = getRecords()
		for rec in recs {
			if let rval = rec.value(ofField: field) {
				switch CNCompareValue(nativeValue0: rval, nativeValue1: val) {
				case .orderedSame:
					result.append(rec)
				case .orderedAscending, .orderedDescending:
					break
				}
			}
		}
		return result
	}

	public func append(record rcd: CNRecord) {
		mSourceTable.append(record: rcd)
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

	public func sort(byDescriptors descs: CNSortDescriptors) {
		mSourceTable.sort(byDescriptors: descs)
	}

	public func toValue() -> CNValue {
		return mSourceTable.toValue()
	}

	private func getRecords() -> Array<CNRecord> {
		let filterfunc = mFilterFunc ?? { (_ rec: CNRecord) -> Bool in return true }
		if mSourceTable.cache.isDirty(cacheId: mCacheId) {
			mRecords       = []
			mRecordIndexes = []
			for i in 0..<mSourceTable.recordCount {
				if let rec = mSourceTable.record(at: i) {
					if filterfunc(rec){
						mRecords.append(rec)
						mRecordIndexes.append(i)
					}
				}
			}
			mSourceTable.cache.setClean(cacheId: mCacheId)
		}
		return mRecords
	}
}
