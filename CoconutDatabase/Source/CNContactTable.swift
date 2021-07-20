/**
 * @file	CNContactTable.swift
 * @brief	Define CNContactTable class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public class CNContactTable: CNNativeTableInterface
{
	public typealias Property = CNContactRecord.Property

	private var mProperties: 	Array<Property>
	private var mPropertyIndices:	Dictionary<String, Int>	// name    -> physical
	private var mRowIndexMap:	Dictionary<Int, Int> 	// logical -> physical
	private var mColumnIndexMap:	Dictionary<Int, Int>	// logical -> physical

	public init(){
		mProperties = [
			.contactType,
			.givenName,
			.middleName,
			.familyName
		]
		mPropertyIndices = [:]
		for i in 0..<mProperties.count {
			let prop = mProperties[i]
			mPropertyIndices[prop.toName()] = i
		}
		mRowIndexMap    = [0:0]
		mColumnIndexMap = [0:0]
	}

	public func load(callback cbfunc: @escaping (_ result: Bool) -> Void)  {
		let db = CNContactDatabase.shared
		db.authorize(callback: {
			(_ granted: Bool) -> Void in
			if granted {
				if db.load() {
					/* Load done */
					/* Make row index map */
					self.mRowIndexMap.removeAll()
					for i in 0..<self.rowCount {
						self.mRowIndexMap[i] = i
					}
					/* Make column index map */
					self.mColumnIndexMap.removeAll()
					for i in 0..<self.columnCount {
						self.mColumnIndexMap[i] = i
					}
					cbfunc(true)
				} else {
					cbfunc(false)
				}
			} else {
				cbfunc(false)
			}
		})
	}

	public var rowCount: Int {
		get {
			let db = CNContactDatabase.shared
			return db.recordCount
		}
	}

	public var columnCount: Int {
		get { return mProperties.count }
	}

	public func title(column cidx: Int) -> String {
		if let prop = property(logicalColumnIndex: cidx) {
			return prop.toName()
		} else {
			CNLog(logLevel: .error, message: "Invalid column index", atFunction: #function, inFile: #file)
			return "?"
		}
	}

	public func setTitle(column cidx: Int, title str: String) {
		CNLog(logLevel: .warning, message: "The title is NOT set: \(str)", atFunction: #function, inFile: #file)
	}

	public func titleIndex(by name: String) -> Int? {	// -> Logical index
		if let idx = mPropertyIndices[name] {
			for (lidx, pidx) in mColumnIndexMap {
				if pidx == idx {
					return lidx
				}
			}
			CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		}
		return nil
	}

	public func value(columnIndex cidx: CNColumnIndex, row ridx: Int) -> CNNativeValue {
		let db = CNContactDatabase.shared
		if let record = db.record(at: physicalRowIndex(fromLogicalRowIndex: ridx)) {
			switch cidx {
			case .number(let num):
				if let prop = property(logicalColumnIndex: num) {
					return record.value(forProperty: prop)
				}
			case .title(let title):
				if let num = self.titleIndex(by: title) {
					if let prop = property(logicalColumnIndex: num){
						return record.value(forProperty: prop)
					}
				}
			@unknown default:
				CNLog(logLevel: .error, message: "Unknown case", atFunction: #function, inFile: #file)
			}
		}
		return .nullValue
	}

	public func setValue(columnIndex cidx: CNColumnIndex, row ridx: Int, value val: CNNativeValue) {
		CNLog(logLevel: .warning, message: "Failed to set value: \(cidx) \(ridx)", atFunction: #function, inFile: #file)
	}

	public func sort(byProperties props: Array<Property>, doAscending doasc: Bool){
		let db = CNContactDatabase.shared
		/* Make array of records */
		var records: Array<CNContactRecord> = []
		for i in 0..<db.recordCount {
			if let rec = db.record(at: i) {
				rec.tag = i
				records.append(rec)
			}
		}
		/* Sort records */
		let newrecords = records.sorted(by: {
			(_ rec0: CNContactRecord, _ rec1: CNContactRecord) -> Bool in
			let result: Bool
			switch rec0.compare(rec1, byProperties: props) {
			case .orderedAscending:  result = doasc
			case .orderedDescending: result = !doasc
			case .orderedSame:	 result = false
			}
			return result
		})
		/* Make new map */
		mRowIndexMap = [:]
		for i in 0..<newrecords.count {
			mRowIndexMap[i] = newrecords[i].tag
		}
	}

	private func property(logicalColumnIndex cidx: Int) -> Property? {
		if let pidx = mColumnIndexMap[cidx] {
			return property(physicalColumnIndex: pidx)
		} else {
			CNLog(logLevel: .error, message: "Unexpected column index: \(cidx)", atFunction: #function, inFile: #file)
			return nil
		}
	}

	private func property(physicalColumnIndex cidx: Int) -> Property? {
		if 0<=cidx && cidx<mProperties.count {
			return mProperties[cidx]
		} else {
			CNLog(logLevel: .error, message: "Invalid column index: \(cidx)", atFunction: #function, inFile: #file)
			return nil
		}
	}

	private func physicalRowIndex(fromLogicalRowIndex ridx: Int) -> Int {
		if let pridx = mRowIndexMap[ridx] {
			return pridx
		} else {
			CNLog(logLevel: .error, message: "Unexpected logical row index: \(ridx)", atFunction: #function, inFile: #file)
			return 0
		}
	}
}

