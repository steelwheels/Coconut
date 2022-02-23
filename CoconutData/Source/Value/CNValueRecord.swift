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
		if let dict = contents() {
			return dict.keys.count
		} else {
			return 0
		}
	}}

	public var fieldNames: Array<String> { get {
		if let dict = contents() {
			return Array(dict.keys)
		} else {
			return []
		}
	}}

	public func value(ofField name: String) -> CNValue? {
		if let dict = contents() {
			return dict[name]
		} else {
			return nil
		}
	}

	public func setValue(value val: CNValue, forField name: String) -> Bool {
		return mTable.setRecordValue(val, index: mIndex, field: name)
	}

	private func contents() -> Dictionary<String, CNValue>? {
		if let dicts = mTable.recordValues() {
			if 0<=mIndex && mIndex < dicts.count {
				return dicts[mIndex]
			}
		}
		return nil
	}
}

/*
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

*/

