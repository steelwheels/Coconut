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

	public init(sourceRecord rec: CNRecord, virtualFields fields: Dictionary<String, VirtualFieldCallback>){
		mSourceRecord		= rec
		mVirtualFieldCallbacks	= fields
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

	public func toValue() -> Dictionary<String, CNValue> {
		return mSourceRecord.toValue()
	}

	public func compare(forField name: String, with rec: CNRecord) -> ComparisonResult {
		let s0 = self.value(ofField: name) ?? CNValue.null
		let s1 = rec.value(ofField: name)  ?? CNValue.null
		return CNCompareValue(nativeValue0: s0, nativeValue1: s1)
	}
}

