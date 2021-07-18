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
	private var mPropertyIndices:	Dictionary<String, Int>
	private var mRowIndexMap:	Dictionary<Int, Int> 	// logical -> physical
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
		mRowIndexMap = [0:0]
	}

	public func load(callback cbfunc: @escaping (_ result: Bool) -> Void)  {
		let db = CNContactDatabase.shared
		db.authorize(callback: {
			(_ granted: Bool) -> Void in
			if granted {
				if db.load() {
					/* Load done */
					/* Make row index map */
					for i in 0..<self.rowCount {
						self.mRowIndexMap[i] = i
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
		if let prop = property(columnIndex: cidx) {
			return prop.toName()
		} else {
			CNLog(logLevel: .error, message: "Invalid column index", atFunction: #function, inFile: #file)
			return "?"
		}
	}

	public func setTitle(column cidx: Int, title str: String) {
		CNLog(logLevel: .warning, message: "The title is NOT set: \(str)", atFunction: #function, inFile: #file)
	}

	public func titleIndex(by name: String) -> Int? {
		if let idx = mPropertyIndices[name] {
			return idx
		} else {
			return nil
		}
	}

	public func value(columnIndex cidx: CNColumnIndex, row ridx: Int) -> CNNativeValue {
		let db = CNContactDatabase.shared
		if let record = db.record(at: physicalRowIndex(fromLogicalRowIndex: ridx)) {
			switch cidx {
			case .number(let num):
				if let prop = property(columnIndex: num) {
					return record.value(forProperty: prop)
				}
			case .title(let title):
				if let num = self.titleIndex(by: title) {
					if let prop = property(columnIndex: num){
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

	private func property(columnIndex cidx: Int) -> Property? {
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

