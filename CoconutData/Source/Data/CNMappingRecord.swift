/**
 * @file	CNMappingRecord.swift
 * @brief	Define CNMappingRecord class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public class CNMappingRecord: CNRecord
{
	public typealias VirtualFieldCallback = CNMappingTable.VirtualFieldCallback

	private var mSourceRecord:		CNRecord
	private var mVirtualFieldCallbacks:	Dictionary<String, VirtualFieldCallback>
	private var mTypes:			Dictionary<String, CNValueType>

	public init(sourceRecord rec: CNRecord, virtualFields fields: Dictionary<String, VirtualFieldCallback>){
		mSourceRecord		= rec
		mVirtualFieldCallbacks	= fields

		mTypes = [:]
		for field in rec.fieldNames {
			if let val = rec.value(ofField: field) {
				mTypes[field] = val.valueType
			}
		}
		for field in mVirtualFieldCallbacks.keys {
			if let cbfunc = mVirtualFieldCallbacks[field] {
				mTypes[field] = cbfunc(self).valueType
			}
		}
	}

	public var index: Int? { get {
		return mSourceRecord.index
	}}

	public var fieldCount: Int { get {
		return mSourceRecord.fieldCount + mVirtualFieldCallbacks.count
	}}

	public var fieldNames: Array<String> { get {
		var names = mSourceRecord.fieldNames
		names.append(contentsOf: mVirtualFieldCallbacks.keys)
		return names
	}}

	public var fieldTypes: Dictionary<String, CNValueType> { get {
		return mTypes
	}}

	public func value(ofField name: String) -> CNValue? {
		if let cbfunc = mVirtualFieldCallbacks[name] {
			return cbfunc(self)
		} else {
			return mSourceRecord.value(ofField: name)
		}
	}

	public func setValue(value val: CNValue, forField name: String) -> Bool {
		if let _ = mVirtualFieldCallbacks[name] {
			CNLog(logLevel: .error, message: "Can not overwrite virtual field: \(name)", atFunction: #function, inFile: #file)
			return false
		} else {
			return mSourceRecord.setValue(value: val, forField: name)
		}
	}

	public func cachedValues() -> Dictionary<String, CNValue>? {
		return mSourceRecord.cachedValues()
	}

	public func compare(forField name: String, with rec: CNRecord) -> ComparisonResult {
		let s0 = self.value(ofField: name) ?? CNValue.null
		let s1 = rec.value(ofField: name)  ?? CNValue.null
		return CNCompareValue(value0: s0, value1: s1)
	}
}

