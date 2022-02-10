/**
 * @file	CNValueTable.swift
 * @brief	Define CNValueTable class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNValueTable: CNTable
{
	private var mPath:		CNValuePath
	private var mValueStorage:	CNValueStorage

	public init(path pth: CNValuePath, valueStorage storage: CNValueStorage) {
		mPath			= pth
		mValueStorage		= storage
	}

	/* The storage which has no file to load/save contents */
	public static func allocateVolatileValueTable() -> CNValueTable {
		let storage  = CNValueStorage.allocateVolatileValueStorage()
		let rootpath = CNValuePath(elements: [.member("root")])
		if !storage.set(value: .arrayValue([]), forPath: rootpath) {
			CNLog(logLevel: .error, message: "Failed to set root data", atFunction: #function, inFile: #file)
		}
		return CNValueTable(path: rootpath, valueStorage: storage)
	}

	public var recordCount: Int { get {
		if let recs = self.recordValues() {
			return recs.count
		} else {
			return 0
		}
	}}

	public var allFieldNames: Array<String> { get {
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

	public func search(value srcval: CNValue, forField field: String) -> Array<CNRecord> {
		guard let values = self.recordValues() else {
			return []
		}
		var result: Array<CNRecord> = []
		let count = values.count
		for i in 0..<count {
			if let dict = values[i].toDictionary() {
				if let dval = dict[field] {
					switch CNCompareValue(nativeValue0: dval, nativeValue1: srcval) {
					case .orderedSame:
						let newrec = CNValueRecord(table: self, index: i)
						result.append(newrec)
					case .orderedAscending, .orderedDescending:
						break
					}
				}
			}
		}
		return result
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


