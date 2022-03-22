/**
 * @file	CNRecord.swift
 * @brief	Define CNRecord class
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public class CNRecord
{
	static let ClassName = "record"

	private var mTable:	CNValueTable?
	private var mIndex:	Int
	private var mCache:	Dictionary<String, CNValue>

	public var index: Int? { get { return mIndex} }

	public init(table tbl: CNValueTable, index idx: Int){
		mTable		= tbl
		mIndex		= idx
		mCache		= [:]
	}

	public init(){
		mTable		= nil
		mIndex		= 0
		mCache		= [:]
	}

	public var fieldCount: Int		{ get {
		if let tbl = mTable {
			return tbl.allFieldNames.count
		} else {
			return mCache.keys.count
		}
	}}

	public var fieldNames: Array<String>	{ get {
		if let tbl = mTable {
			return tbl.allFieldNames
		} else {
			return Array(mCache.keys)
		}
	}}
	
	public func value(ofField name: String) -> CNValue? {
		if let tbl = mTable {
			return tbl.getRecordValue(index: mIndex, field: name)
		} else {
			return mCache[name]
		}
	}

	public func setValue(value val: CNValue, forField name: String) -> Bool {
		if let tbl = mTable {
			return tbl.setRecordValue(val, index: mIndex, field: name)
		} else {
			mCache[name] = val
			return true
		}
	}

	public func toValue() -> Dictionary<String, CNValue> {
		var result: Dictionary<String, CNValue> = [:]
		for field in self.fieldNames {
			if let val = value(ofField: field) {
				result[field] = val
			}
		}
		CNValue.setClassName(toValue: &result, className: CNRecord.ClassName)
		return result
	}

	static func fromValue(value val: Dictionary<String, CNValue>) -> CNRecord? {
		if CNValue.hasClassName(inValue: val, className: CNRecord.ClassName) {
			var dupval = val ; CNValue.removeClassName(fromValue: &dupval)
			let newrec = CNRecord()
			newrec.mCache = dupval
			return newrec
		} else {
			return nil
		}
	}

	public func compare(forField name: String, with rec: CNRecord) -> ComparisonResult {
		let s0 = self.value(ofField: name) ?? .nullValue
		let s1 = rec.value(ofField: name)  ?? .nullValue
		return CNCompareValue(nativeValue0: s0, nativeValue1: s1)
	}
}


