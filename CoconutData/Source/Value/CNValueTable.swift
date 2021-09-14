/**
 * @file	CNValueTable.swift
 * @brief	Define CNValueTable class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public protocol CNRecord
{
	var fieldCount: Int { get }
	var fieldNames: Array<String> { get }

	func value(ofField name: String) -> CNValue?
	func setValue(value val: CNValue, forField name: String) -> Bool

	var isDirty: Bool { get }
	func save()
}

public enum CNTableLoadResult {
	case ok
	case error(NSError)
}

public protocol CNTable
{
	var recordCount: Int { get }

	func load(URL url: URL?) -> CNTableLoadResult

	func newRecord() -> CNRecord
	func record(at row: Int) -> CNRecord?
	func append(record rcd: CNRecord)
	func forEach(callback cbfunc: (_ record: CNRecord) -> Void)

	func sort(byDescriptors descs: CNSortDescriptors)
	func save()
}

extension CNRecord
{
	public func compare(forField name: String, with rec: CNRecord) -> ComparisonResult {
		let s0 = self.value(ofField: name) ?? .nullValue
		let s1 = rec.value(ofField: name)  ?? .nullValue
		return CNCompareValue(nativeValue0: s0, nativeValue1: s1)
	}
}

extension CNTable
{
	public var isDirty: Bool { get {
		var result = false
		for i in 0..<self.recordCount {
			if let rec = self.record(at: i) {
				if rec.isDirty {
					result = true
					break
				}
			}
		}
		return result
	}}

	public func toNativeValue() -> CNValue {
		var result: Array<CNValue> = []
		self.forEach(callback: {
			(_ record: CNRecord) -> Void in
			if let rec = record as? CNValueRecord {
				result.append(rec.toNativeValue())
			}
		})
		return .arrayValue(result)
	}
}

public class CNValueRecord: CNRecord
{
	private var mValues:	Dictionary<String, CNValue>
	private var mIsDirty:	Bool

	public init(){
		mValues		= [:]
		mIsDirty	= false
	}

	public var fieldCount: Int { get {
		return mValues.count
	}}

	public var fieldNames: Array<String> { get {
		return Array(mValues.keys.sorted())
	}}

	public var isDirty: Bool { get { return mIsDirty }}

	public func value(ofField name: String) -> CNValue? {
		return mValues[name]
	}

	public func setValue(value val: CNValue, forField name: String) -> Bool {
		mValues[name] = val
		mIsDirty = true
		return true
	}

	public func toNativeValue() -> CNValue {
		return .dictionaryValue(mValues)
	}

	public func save(){
		CNLog(logLevel: .error, message: "Save is not supported", atFunction: #function, inFile: #file)
		mIsDirty = false
	}
}

public class CNValueTable: CNTable
{
	private var mRecords:		Array<CNValueRecord>

	public init() {
		mRecords 	= []
	}

	public var recordCount: Int { get {
		return mRecords.count
	}}

	public func newRecord() -> CNRecord {
		return CNValueRecord()
	}

	public func record(at row: Int) -> CNRecord? {
		if 0<=row && row < mRecords.count {
			return mRecords[row]
		} else {
			return nil
		}
	}

	public func append(record rcd: CNRecord) {
		if let nrcd = rcd as? CNValueRecord {
			mRecords.append(nrcd)
		} else {
			CNLog(logLevel: .error, message: "Unexpected record type", atFunction: #function, inFile: #file)
		}
	}

	public func forEach(callback cbfunc: (_ record: CNRecord) -> Void) {
		do {
			try mRecords.forEach({
				(_ record: CNRecord) throws -> Void in
				cbfunc(record)
			})
		} catch let err as NSError {
			CNLog(logLevel: .error, message: err.description, atFunction: #function, inFile: #file)
		}
	}

	public func sort(byDescriptors desc: CNSortDescriptors) {
		mRecords = desc.sort(source: mRecords, comparator: {
			(_ rec0: CNValueRecord, _ rec1: CNValueRecord, _ key: String) -> ComparisonResult in
			return rec0.compare(forField: key, with: rec1)
		})
	}

	public func load(URL urlp: URL?) -> CNTableLoadResult {
		if let url = urlp {
			if let str = url.loadContents() {
				return load(source: str as String)
			} else {
				return .error(NSError.parseError(message: "Failed to load from \(url.path)"))
			}
		} else {
			return .error(NSError.parseError(message: "No valid URL", location: #function))
		}
	}

	public func load(source src: String) -> CNTableLoadResult {
		let parser = CNValueParser()
		switch parser.parse(source: src) {
		case .ok(let val):
			return load(nativeValue: val)
		case .error(let err):
			return .error(err)
		}
	}

	public func load(nativeValue nvalue: CNValue) -> CNTableLoadResult {
		switch nvalue {
		case .arrayValue(let arr):
			return load(arrayValue: arr)
		default:
			let err = NSError.parseError(message: "Not table format", location: #function)
			return .error(err)
		}
	}

	public static let HEADER_PROPERTY = "headers"
	public static let DATA_PROPERTY   = "data"


	private func load(arrayValue nvalue: Array<CNValue>) -> CNTableLoadResult {
		/* Reset content */
		self.reset()
		var ridx: Int = 0
		for val in nvalue {
			switch val {
			case .dictionaryValue(let dict):
				let newrec = CNValueRecord()
				for (key, val) in dict {
					if !newrec.setValue(value: val, forField: key){
						CNLog(logLevel: .error, message: "Failed to setup record", atFunction: #function, inFile: #file)
					}
				}
				self.append(record: newrec)
			default:
				let err = NSError.parseError(message: "Object data is required", location: #function)
				return .error(err)
			}
			/* Update row index */
			ridx += 1
		}
		return .ok
	}

	public func save() {

	}

	private func reset() {
		mRecords 	= []
	}
}

