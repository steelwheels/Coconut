/**
 * @file	CNStorageRecord.swift
 * @brief	Define CNRecord class
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public class CNStorageRecord: CNRecord
{
	public static let 	RecordIdItem	= "recordId"

	static let 		ClassName = "record"

	private enum SourceData {
		case table(CNStorageTable, Int)			// (Source table, index)
		case cache(Dictionary<String, CNValue>)		// (property-name, property-value)
	}

	private var mTypes:	Dictionary<String, CNValueType>
	private var mSource:	SourceData

	public var index: Int? { get {
		switch mSource {
		case .table(_, let idx):	return idx
		case .cache(_):			return nil
		}
	}}

	public init(table tbl: CNStorageTable, index idx: Int){
		mSource	= .table(tbl, idx)
		mTypes  = CNStorageRecord.defaultTypes(fields: tbl.defaultFields)

	}

	public init(defaultFields fields: Dictionary<String, CNValue>){
		mSource = .cache(fields)
		mTypes  = CNStorageRecord.defaultTypes(fields: fields)
	}

	private static func defaultTypes(fields flds: Dictionary<String, CNValue>) -> Dictionary<String, CNValueType> {
		var result: Dictionary<String, CNValueType> = [:]
		for fname in flds.keys {
			if let val = flds[fname] {
				result[fname] = val.valueType
			}
		}
		return result
	}

	public var fieldCount: Int		{ get {
		switch mSource {
		case .table(let tbl, _):
			return tbl.defaultFields.count
		case .cache(let dict):
			return dict.count
		}
	}}

	public var fieldNames: Array<String>	{ get {
		switch mSource {
		case .table(let tbl, _):
			return Array(tbl.defaultFields.keys)
		case .cache(let dict):
			return Array(dict.keys)
		}
	}}

	public var fieldTypes: Dictionary<String, CNValueType> { get {
		return mTypes
	}}

	public func value(ofField name: String) -> CNValue? {
		switch mSource {
		case .table(let tbl, let idx):
			if let val = tbl.getRecordValue(index: idx, field: name) {
				return val
			} else {
				return tbl.defaultFields[name]
			}
		case .cache(let dict):
			return dict[name]
		}
	}

	public func setValue(value val: CNValue, forField name: String) -> Bool {
		switch mSource {
		case .table(let tbl, let idx):
			if let curval = tbl.getRecordValue(index: idx, field: name) {
				if CNIsSameValue(nativeValue0: curval, nativeValue1: val) {
					return true // already set
				}
				let cval = CNCastValue(from: val, to: curval.valueType)
				return tbl.setRecordValue(cval, index: idx, field: name)
			} else {
				return tbl.setRecordValue(val, index: idx, field: name)
			}
		case .cache(let dict):
			var newdict   = dict
			let newval: CNValue
			if let curval = newdict[name] {
				newval = CNCastValue(from: val, to: curval.valueType)
			} else {
				newval = val
			}
			newdict[name] = newval
			mSource       = .cache(newdict)
			return true
		}
	}

	public func cachedValues() -> Dictionary<String, CNValue>? {
		switch mSource {
		case .table(_, _):
			return nil
		case .cache(let dict):
			return dict
		}
	}

	public func toDictionary() -> Dictionary<String, CNValue> {
		var result: Dictionary<String, CNValue> = [:]
		for field in self.fieldNames.sorted() {
			if let val = value(ofField: field) {
				result[field] = val
			}
		}
		CNValue.setClassName(toValue: &result, className: CNStorageRecord.ClassName)
		return result
	}

	public static func fromDictionary(value val: Dictionary<String, CNValue>) -> CNRecord? {
		if CNValue.hasClassName(inValue: val, className: CNStorageRecord.ClassName) {
			var dupval = val ; CNValue.removeClassName(fromValue: &dupval)
			let newrec = CNStorageRecord(defaultFields: dupval)
			return newrec
		} else {
			return nil
		}
	}

	public func compare(forField name: String, with rec: CNRecord) -> ComparisonResult {
		let s0 = self.value(ofField: name) ?? CNValue.null
		let s1 = rec.value(ofField: name)  ?? CNValue.null
		return CNCompareValue(nativeValue0: s0, nativeValue1: s1)
	}
}


