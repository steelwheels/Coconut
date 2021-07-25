/**
 * @file	CNNaviveValueTable.swift
 * @brief	Define CNNativeValueTable class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

private class CNNativeValueRecord
{
	private var mValues:	Array<CNNativeValue>

	public var count: Int { get { return mValues.count }}

	public init() {
		mValues = []
	}

	public func value(at idx: Int) -> CNNativeValue {
		if 0<=idx && idx<mValues.count {
			return mValues[idx]
		} else {
			return .nullValue
		}
	}

	public func setValue(at idx: Int, value val: CNNativeValue){
		expand(size: idx+1)
		mValues[idx] = val
	}

	public func compare(at idx: Int, with rec: CNNativeValueRecord) -> ComparisonResult {
		let s0 = self.value(at: idx)
		let s1 = rec.value(at: idx)
		return CNCompareNativeValue(nativeValue0: s0, nativeValue1: s1)
	}

	private func expand(size sz: Int){
		let diff = sz - mValues.count
		if diff > 0 {
			for _ in 0..<diff {
				mValues.append(.nullValue)
			}
		}
	}
}

public enum CNColumnIndex {
	case 	number(Int)
	case	title(String)
}

public protocol CNNativeTableInterface
{
	func title(column cidx: Int) -> String
	func setTitle(column cidx: Int, title str: String)
	func titleIndex(by name: String) -> Int?

	var isEditable:		Bool		{ get }
	var rowCount:		Int		{ get }
	var columnCount:	Int		{ get }

	func value(columnIndex cidx: CNColumnIndex, row ridx: Int) -> CNNativeValue
	func setValue(columnIndex cidx: CNColumnIndex, row ridx: Int, value val: CNNativeValue)

	func sort(byDescriptors descs: CNSortDescriptors)
}

open class CNNativeValueTable: CNNativeTableInterface
{
	public enum Format {
	case sheet	// default
	case records
	}

	private var mTitles:		Dictionary<String, Int>
	private var mFormat:		Format
	private var mRecords:		Array<CNNativeValueRecord>
	private var mMaxRowCount:	Int
	private var mMaxColumnCount:	Int

	public var format:	Format	{ get { return mFormat		}}
	public var titleCount:	Int	{ get { return mTitles.count	}}

	public var isEditable:	 Bool	{ get { return true 		}}
	public var rowCount:    Int	{ get { return mMaxRowCount	}}
	public var columnCount: Int	{ get { return mMaxColumnCount	}}

	public init(){
		mFormat		= .sheet
		mTitles		= [:]
		mRecords	= []
		mMaxRowCount	= 0
		mMaxColumnCount	= 0
	}

	public func reset() {
		mFormat 	= .sheet
		mTitles		= [:]
		mRecords	= []
		mMaxRowCount	= 0
		mMaxColumnCount	= 0
	}

	private static func indexToString(index idx: Int) -> String {
		return "\(idx)"
	}

	public func title(column cidx: Int) -> String {
		for (title, idx) in mTitles {
			if idx == cidx {
				return title
			}
		}
		let newttl = CNNativeValueTable.indexToString(index: cidx)
		mTitles[newttl] = cidx
		return newttl
	}

	public func setTitle(column cidx: Int, title str: String){
		mTitles[str]    = cidx
		mMaxColumnCount = max(mMaxColumnCount, mTitles.count)
	}

	public func titleIndex(by name: String) -> Int? {
		return mTitles[name]
	}

	public func value(columnIndex cidx: CNColumnIndex, row ridx: Int) -> CNNativeValue {
		switch cidx {
		case .number(let num):
			return value(column: num, row: ridx)
		case .title(let str):
			if let num = titleIndex(by: str) {
				return value(column: num, row: ridx)
			} else {
				return .nullValue
			}
		}
	}

	private func value(column cidx: Int, row ridx: Int) -> CNNativeValue {
		if 0<=ridx && ridx<mRecords.count {
			return mRecords[ridx].value(at: cidx)
		} else {
			return .nullValue
		}
	}

	public func setValue(columnIndex cidx: CNColumnIndex, row ridx: Int, value val: CNNativeValue){
		switch cidx {
		case .number(let num):
			setValue(column: num, row: ridx, value: val)
		case .title(let str):
			if let num = titleIndex(by: str) {
				setValue(column: num, row: ridx, value: val)
			} else {
				CNLog(logLevel: .error, message: "Failed to set value: title=\(str) row:\(ridx) value=\(val)", atFunction: #function, inFile: #file)
			}
		}
	}

	private func setValue(column cidx: Int, row ridx: Int, value val: CNNativeValue) {
		expandRows(size: ridx + 1)
		let rec = mRecords[ridx]
		rec.setValue(at: cidx, value: val)
		mMaxColumnCount = max(mMaxColumnCount, rec.count)
	}

	private func expandRows(size sz: Int){
		if sz > mRecords.count {
			let diff = sz - mRecords.count
			for _ in 0..<diff {
				mRecords.append(CNNativeValueRecord())
			}
			mMaxRowCount = max(mMaxRowCount, sz)
		}
	}

	public enum LoadResult {
		case 	ok
		case	error(CNNativeValueParser.ParseError)
	}

	public func load(source src: String) -> LoadResult {
		let parser = CNNativeValueParser()
		switch parser.parse(source: src) {
		case .ok(let val):
			return load(nativeValue: val)
		case .error(let err):
			return .error(err)
		}
	}

	public func load(nativeValue nvalue: CNNativeValue) -> LoadResult {
		switch nvalue {
		case .dictionaryValue(let dict):
			return load(dictionaryValue: dict)
		case .arrayValue(let arr):
			return load(arrayValue: arr)
		default:
			let err = CNParseError.ParseError(0, "Not table format")
			return .error(.tokenError(err))
		}
	}

	public func sort(byDescriptors desc: CNSortDescriptors) {
		mRecords = desc.sort(source: mRecords, comparator: {
			(_ rec0: CNNativeValueRecord, _ rec1: CNNativeValueRecord, _ key: String) -> ComparisonResult in
			if let idx = titleIndex(by: key) {
				return rec0.compare(at: idx, with: rec1)
			} else {
				CNLog(logLevel: .error, message: "Unknown title: \(key)", atFunction: #function, inFile: #file)
				return .orderedSame
			}
		})
	}

	public static let HEADER_PROPERTY = "headers"
	public static let DATA_PROPERTY   = "data"

	private func load(dictionaryValue nvalue: Dictionary<String, CNNativeValue>) -> LoadResult {
		/* Reset content */
		self.reset()
		/* Set format */
		self.mFormat = .sheet

		if let hdrval = nvalue[CNNativeValueTable.HEADER_PROPERTY] {
			switch hdrval {
			case .arrayValue(let arr):
				var index: Int = 0
				for titleval in arr {
					if let title = decodeTitle(value: titleval) {
						if let _ = self.titleIndex(by: title) {
							/* Already defined */
							let err = CNParseError.ParseError(0, "Multi defined column name: \(title)")
							return .error(.tokenError(err))
						} else {
							self.setTitle(column: index, title: title)
						}
					}
					index += 1
				}
			default:
				let err = CNParseError.ParseError(0, "Array of column titles are require")
				return .error(.tokenError(err))
			}
		}
		if let dataval = nvalue[CNNativeValueTable.DATA_PROPERTY] {
			switch dataval {
			case .arrayValue(let arr0):
				var ridx: Int = 0
				for rowval in arr0 {
					switch rowval {
					case .arrayValue(let arr1):
						var cidx: Int = 0
						for col in arr1 {
							self.setValue(column: cidx, row: ridx, value: col)
							cidx += 1
						}
					default:
						let err = CNParseError.ParseError(0, "Not array data in the row \(ridx) in \"data\" section")
						return .error(.tokenError(err))
					}
					ridx += 1
				}
			default:
				let err = CNParseError.ParseError(0, "Not array data in \"data\" section")
				return .error(.tokenError(err))
			}
		} else {
			let err = CNParseError.ParseError(0, "No data section")
			return .error(.tokenError(err))
		}
		return .ok
	}

	private func load(arrayValue nvalue: Array<CNNativeValue>) -> LoadResult {
		/* Reset content */
		self.reset()
		/* Set format */
		self.mFormat = .records

		var ridx: Int = 0
		for val in nvalue {
			switch val {
			case .dictionaryValue(let dict):
				for (key, val) in dict {
					/* Set column title */
					if let _ = self.titleIndex(by: key) {
						/* Already exist */
					} else {
						self.setTitle(column: self.titleCount, title: key)
					}
					/* Set value */
					self.setValue(columnIndex: .title(key), row: ridx, value: val)
				}
			default:
				let err = CNParseError.ParseError(0, "Object data is required")
				return .error(.tokenError(err))
			}
			/* Update row index */
			ridx += 1
		}
		return .ok
	}

	private func decodeTitle(value val: CNNativeValue) -> String? {
		let result: String?
		switch val {
		case .stringValue(let str):
			result = str
		case .nullValue:
			result = nil
		default:
			result = val.toString()
		}
		return result
	}

	public func toNativeValue() -> CNNativeValue {
		switch mFormat {
		case .sheet:
			return toSheetValue()
		case .records:
			return toRecordValue()
		}

	}

	private func toSheetValue() -> CNNativeValue {
		/* Make title array */
		var titlevals: Array<CNNativeValue> = []
		for i in 0..<mTitles.count {
			let str = self.title(column: i)
			titlevals.append(.stringValue(str))
		}

		/* Make data array */
		var datavals: Array<CNNativeValue> = []
		for ridx in 0..<self.rowCount {
			var rowvals: Array<CNNativeValue> = []
			for cidx in 0..<self.columnCount {
				let val = self.value(column: cidx, row: ridx)
				rowvals.append(val)
			}
			datavals.append(.arrayValue(rowvals))
		}
		var result: Dictionary<String, CNNativeValue> = [:]
		result[CNNativeValueTable.HEADER_PROPERTY] = .arrayValue(titlevals)
		result[CNNativeValueTable.DATA_PROPERTY]   = .arrayValue(datavals)
		return .dictionaryValue(result)
	}

	private func toRecordValue() -> CNNativeValue {
		var result: Array<CNNativeValue> = []
		for ridx in 0..<self.rowCount {
			var record: Dictionary<String, CNNativeValue> = [:]
			for cidx in 0..<self.columnCount {
				let title = self.title(column: cidx)
				let val   = self.value(columnIndex: .title(title), row: ridx)
				switch val {
				case .nullValue:
					break // ignore null data
				default:
					record[title] = val
				}
			}
			result.append(.dictionaryValue(record))
		}
		return .arrayValue(result)
	}
}




