/**
 * @file	CNNaviveValueTable.swift
 * @brief	Define CNNativeValueTable class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

private class CNNativeValueTitles
{
	private var mTitles:		Array<String?>
	private var mDictionary:	Dictionary<String, Int>

	public var count: Int { get { return mTitles.count }}

	public init(){
		mTitles     = []
		mDictionary = [:]
	}

	public func copy(from titles: CNNativeValueTitles){
		mTitles		= titles.mTitles
		mDictionary	= titles.mDictionary
	}

	public func title(at idx: Int) -> String? {
		if 0<=idx && idx<mTitles.count {
			return mTitles[idx]
		} else {
			return nil
		}
	}

	public func index(by title: String) -> Int? {
		return mDictionary[title]
	}

	public func setTitle(at idx: Int, title str: String) {
		expand(size: idx + 1)
		mTitles[idx] = str
		mDictionary[str] = idx
	}

	private func expand(size sz: Int){
		let diff = sz - mTitles.count
		if diff > 0 {
			for _ in 0..<diff {
				mTitles.append(nil)
			}
		}
	}
}

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

	private func expand(size sz: Int){
		let diff = sz - mValues.count
		if diff > 0 {
			for _ in 0..<diff {
				mValues.append(.nullValue)
			}
		}
	}
}

open class CNNativeValueTable
{
	public enum Format {
	case unknown
	case sheet
	case records
	}

	private var mTitles:		CNNativeValueTitles
	private var mRecords:		Array<CNNativeValueRecord>
	private var mMaxRowCount:	Int
	private var mMaxColumnCount:	Int

	public var format:	Format
	public var titleCount:	Int { get { return mTitles.count	}}
	public var rowCount:    Int { get { return mMaxRowCount		}}
	public var columnCount: Int { get { return mMaxColumnCount	}}

	public init(){
		format		= .unknown
		mTitles		= CNNativeValueTitles()
		mRecords	= []
		mMaxRowCount	= 0
		mMaxColumnCount	= 0
	}

	public func copy(from vtable: CNNativeValueTable){
		self.format 		= vtable.format
		self.mTitles.copy(from: vtable.mTitles)
		self.mRecords		= vtable.mRecords
		self.mMaxRowCount	= vtable.mMaxRowCount
		self.mMaxColumnCount	= vtable.mMaxColumnCount
	}

	public func reset() {
		format 		= .unknown
		mTitles		= CNNativeValueTitles()
		mRecords	= []
		mMaxRowCount	= 0
		mMaxColumnCount	= 0
	}

	public func title(column cidx: Int) -> String {
		if let ttl = mTitles.title(at: cidx) {
			return ttl
		} else {
			let newttl = "_\(cidx)"
			setTitle(column: cidx, title: newttl)
			return newttl
		}
	}

	public func setTitle(column cidx: Int, title str: String){
		mTitles.setTitle(at: cidx, title: str)
		mMaxColumnCount = max(mMaxColumnCount, mTitles.count)
	}

	public func titleIndex(by name: String) -> Int? {
		return mTitles.index(by: name)
	}

	public func value(column cidx: Int, row ridx: Int) -> CNNativeValue {
		if 0<=ridx && ridx<mRecords.count {
			return mRecords[ridx].value(at: cidx)
		} else {
			return .nullValue
		}
	}

	public func value(title ttl: String, row ridx: Int) -> CNNativeValue {
		if let cidx = titleIndex(by: ttl) {
			if 0<=ridx && ridx<mRecords.count {
				return mRecords[ridx].value(at: cidx)
			}
		}
		return .nullValue
	}

	public func setValue(column cidx: Int, row ridx: Int, value val: CNNativeValue) {
		expandRows(size: ridx + 1)
		let rec = mRecords[ridx]
		rec.setValue(at: cidx, value: val)
		mMaxColumnCount = max(mMaxColumnCount, rec.count)
	}

	public func setValue(title ttl: String, row ridx: Int, value val: CNNativeValue) {
		if let cidx = titleIndex(by: ttl) {
			expandRows(size: ridx + 1)
			let rec = mRecords[ridx]
			rec.setValue(at: cidx, value: val)
			mMaxColumnCount = max(mMaxColumnCount, rec.count)
		} else {
			CNLog(logLevel: .error, message: "Failed to set value", atFunction: #function, inFile: #file)
		}
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

	public static let HEADER_PROPERTY = "headers"
	public static let DATA_PROPERTY   = "data"

	private func load(dictionaryValue nvalue: Dictionary<String, CNNativeValue>) -> LoadResult {
		/* Reset content */
		self.reset()
		/* Set format */
		self.format = .sheet

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
		self.format = .records

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
					self.setValue(title: key, row: ridx, value: val)
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

	public func toNativeValue(format form: Format) -> CNNativeValue {
		switch form {
		case .unknown, .sheet:
			return toSheetValue()
		case .records:
			return toRecordValue()
		}

	}

	private func toSheetValue() -> CNNativeValue {
		/* Make title array */
		var titlevals: Array<CNNativeValue> = []
		for i in 0..<mTitles.count {
			if let str = mTitles.title(at: i) {
				titlevals.append(.stringValue(str))
			}
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
				let val   = self.value(title: title, row: ridx)
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

