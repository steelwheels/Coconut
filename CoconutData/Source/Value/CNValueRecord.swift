/**
 * @file	CNValueRecord.swift
 * @brief	Define CNValueTable class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNValueRecord: CNRecord
{
	private var mTable:	CNValueTable
	private var mIndex:	Int

	public init(table tbl: CNValueTable, index idx: Int){
		mTable	= tbl
		mIndex	= idx
	}

	public var fieldCount: Int { get {
		if let rec = mTable.recordValue(at: mIndex) {
			return rec.count
		} else {
			return 0
		}
	}}

	public var fieldNames: Array<String> { get {
		if let rec = mTable.recordValue(at: mIndex) {
			var result: Array<String> = []
			for (key, _) in rec {
				result.append(key)
			}
			return result
		} else {
			return []
		}
	}}

	public func value(ofField name: String) -> CNValue? {
		if let rec = mTable.recordValue(at: mIndex) {
			return rec[name]
		} else {
			return nil
		}
	}

	public func setValue(value val: CNValue, forField name: String) -> Bool {
		if var rec = mTable.recordValue(at: mIndex) {
			rec[name] = val
			return mTable.setRecordValue(value: rec, at: mIndex)
		} else {
			return false
		}
	}
}

/*
public class CNValueRecord: CNRecord
{
	private var mValues:	Dictionary<String, CNValue>

	public init(){
		mValues		= [:]
	}

	public var fieldCount: Int { get {
		return mValues.count
	}}

	public var fieldNames: Array<String> { get {
		return Array(mValues.keys.sorted())
	}}

	public func value(ofField name: String) -> CNValue? {
		return mValues[name]
	}

	public func setValue(value val: CNValue, forField name: String) -> Bool {
		mValues[name] = val
		return true
	}

	public func toValue() -> CNValue {
		return .dictionaryValue(mValues)
	}
}

*/

