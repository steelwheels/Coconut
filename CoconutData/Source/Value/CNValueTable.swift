/**
 * @file	CNValueTable.swift
 * @brief	Define CNValueTable class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNValueTable: CNTable
{
	private var mPath:		Array<String>
	private var mValueStorage:	CNValueStorage

	public init(path pth: Array<String>, valueStorage storage: CNValueStorage) {
		mPath		= pth
		mValueStorage	= storage
	}

	/* The storage which has no file to load/save contents */
	public static func allocateVolatileValueTable() -> CNValueTable {
		let storage = CNValueStorage.allocateVolatileValueStorage()
		if !storage.set(value: .arrayValue([]), forPath: ["root"]){
			CNLog(logLevel: .error, message: "Failed to set root data", atFunction: #function, inFile: #file)
		}
		return CNValueTable(path: ["root"], valueStorage: storage)
	}

	public var recordCount: Int { get {
		if let recs = self.recordValues() {
			return recs.count
		} else {
			return 0
		}
	}}

	public var fieldNames: Array<String> { get {
		if let recs = self.recordValues() {
			var result: Array<String> = []
			for rec in recs {
				if let dict = rec.toDictionary() {
					for (key, _) in dict {
						if !result.contains(key) {
							result.append(key)
						}
					}
				} else {
					CNLog(logLevel: .error, message: "Invalid data structure for record", atFunction: #function, inFile: #file)
				}
			}
			return result
		} else {
			return []
		}
	}}

	public func newRecord() -> CNRecord {
		if self.addRecord() {
			if let rec = record(at: self.recordCount - 1) {
				return rec
			}
		}
		/* Failed to allocate */
		CNLog(logLevel: .error, message: "Failed to allocate new record", atFunction: #function, inFile: #file)
		return CNValueRecord(table: self, index: 0)
	}

	public func record(at row: Int) -> CNRecord? {
		if let recs = self.recordValues() {
			if 0<=row && row<recs.count {
				return CNValueRecord(table: self, index: row)
			}
		}
		return nil
	}

	public func append(record rcd: CNRecord) {
		// Nothing have to do (Already added at newRecord())
	}

	public func forEach(callback cbfunc: (CNRecord) -> Void) {
		if let recs = self.recordValues() {
			for i in 0..<recs.count {
				let newrec = CNValueRecord(table: self, index: i)
				cbfunc(newrec)
			}
		} else {
			/* Failed to execute */
			CNLog(logLevel: .error, message: "Failed to execute forEach", atFunction: #function, inFile: #file)
		}
	}

	public func sort(byDescriptors descs: CNSortDescriptors) {
		CNLog(logLevel: .error, message: "Not supported", atFunction: #function, inFile: #file)
	}

	private func recordValues() -> Array<CNValue>? {
		if let val = mValueStorage.value(forPath: mPath) {
			if let arr = val.toArray() {
				return arr
			}
		}
		CNLog(logLevel: .error, message: "Invalid data structure for table", atFunction: #function, inFile: #file)
		return nil
	}

	public func recordValue(at idx: Int) -> Dictionary<String, CNValue>? {
		if let vals = recordValues() {
			if 0<=idx && idx<vals.count {
				return vals[idx].toDictionary()
			} else {
				CNLog(logLevel: .error, message: "Invalid index: \(idx)", atFunction: #function, inFile: #file)
			}
		}
		return nil
	}

	public func setRecordValue(value val: Dictionary<String, CNValue>, at idx: Int) -> Bool {
		if let orgval = mValueStorage.value(forPath: mPath) {
			if var arr = orgval.toArray() {
				if 0<=idx && idx<arr.count {
					arr[idx] = .dictionaryValue(val)
					return mValueStorage.set(value: .arrayValue(arr), forPath: mPath)
				}
			}
		}
		return false
	}

	private func addRecord() -> Bool {
		if let val = mValueStorage.value(forPath: mPath) {
			if var newarr = val.toArray() {
				newarr.append(.dictionaryValue([:]))
				if mValueStorage.set(value: .arrayValue(newarr), forPath: mPath) {
					return true
				}
			}
		}
		CNLog(logLevel: .error, message: "Failed to append record", atFunction: #function, inFile: #file)
		return false
	}
}

/*
public class CNValueTable: CNTable
{
	private var mRecords:		Array<CNValueRecord>
	private var mFieldNames:	Array<String>

	public init() {
		mRecords 	= []
		mFieldNames	= []
	}

	public var recordCount: Int { get {
		return mRecords.count
	}}

	private var mPreviousRecordCount: Int = 0

	public var fieldNames: Array<String> { get {
		if mPreviousRecordCount != mRecords.count {
			var newnames: Array<String> = []
			self.forEach(callback: {
				(_ record: CNRecord) -> Void in
				let names = record.fieldNames
				for name in names {
					if let _ = newnames.firstIndex(of: name) {
						/* Already stored */
					} else {
						newnames.append(name)
					}
				}
			})
			mFieldNames = newnames
			mPreviousRecordCount = mRecords.count
		}
		return mFieldNames
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

	public func load(fromURL urlp: URL?) -> CNTableLoadResult {
		if let url = urlp {
			if let str = url.loadContents() {
				return load(fromSource: str as String)
			} else {
				return .error(NSError.parseError(message: "Failed to load from \(url.path)"))
			}
		} else {
			return .error(NSError.parseError(message: "No valid URL", location: #function))
		}
	}

	public func load(fromSource src: String) -> CNTableLoadResult {
		let parser = CNValueParser()
		switch parser.parse(source: src) {
		case .ok(let val):
			return load(fromValue: val)
		case .error(let err):
			return .error(err)
		}
	}

	public func load(fromValue nvalue: CNValue) -> CNTableLoadResult {
		switch nvalue {
		case .arrayValue(let arr):
			return load(arrayValue: arr)
		default:
			let err = NSError.parseError(message: "Not table format", location: #function)
			return .error(err)
		}
	}

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

	private func reset() {
		mRecords 	= []
	}
}
*/

