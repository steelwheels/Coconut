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
	private var mTitles:		CNNativeValueTitles
	private var mRecords:		Array<CNNativeValueRecord>
	private var mMaxRowCount:	Int
	private var mMaxColumnCount:	Int

	public var rowCount:    Int { get { return mMaxRowCount		}}
	public var columnCount: Int { get { return mMaxColumnCount	}}

	public init(){
		mTitles		= CNNativeValueTitles()
		mRecords	= []
		mMaxRowCount	= 0
		mMaxColumnCount	= 0
	}

	public func copy(from vtable: CNNativeValueTable){
		self.mTitles.copy(from: vtable.mTitles)
		self.mRecords		= vtable.mRecords
		self.mMaxRowCount	= vtable.mMaxRowCount
		self.mMaxColumnCount	= vtable.mMaxColumnCount
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

	private func load(nativeValue nvalue: CNNativeValue) -> LoadResult {
		/* Reset current content */
		mTitles		= CNNativeValueTitles()
		mRecords	= []
		mMaxRowCount	= 0
		mMaxColumnCount	= 0

		switch nvalue {
		case .arrayValue(let arr0):
			var haserr	= false
			var rowidx	= 0
			for val in arr0	 {
				switch val {
				case .arrayValue(let arr1):
					var colidx: Int = 0
					for elm in arr1 {
						setValue(column: colidx, row: rowidx, value: elm)
						colidx += 1
					}
				case .stringValue(_), .numberValue(_):
					setValue(column: 0, row: rowidx, value: val)
				default:
					haserr = true
				}
				if haserr {
					break
				}
				rowidx += 1
			}
			if !haserr {
				return .ok
			}
		case .dictionaryValue(let dict0):
			var haserr	= false
			var colidx	= 0
			for (key, val) in dict0	 {
				switch val {
				case .arrayValue(let arr0):
					var rowidx: Int = 0
					for elm in arr0 {
						setTitle(column: colidx, title: key)
						setValue(title: key, row: rowidx, value: elm)
						rowidx += 1
					}
				case .stringValue(_), .numberValue(_):
					setValue(title: key, row: 0, value: val)
				default:
					haserr = true
				}
				if haserr {
					break
				}
				colidx += 1
			}
			if !haserr {
				return .ok
			}
		default:
			break
		}
		let err = CNParseError.ParseError(0, "Not 2D array format")
		return .error(.tokenError(err))
	}

	public func toNativeValue() -> CNNativeValue {
		var result: Array<CNNativeValue> = []
		for ridx in 0..<mMaxRowCount {
			var row: Array<CNNativeValue> = []
			for cidx in 0..<mMaxColumnCount {
				let val = value(column: cidx, row: ridx)
				row.append(val)
			}
			result.append(.arrayValue(row))
		}
		return .arrayValue(result)
	}
}

