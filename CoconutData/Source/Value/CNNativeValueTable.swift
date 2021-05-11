/**
 * @file	CNNaviveValueTable.swift
 * @brief	Define CNNativeValueTable class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNNativeValueRecord
{
	private var mValues:	Array<CNNativeValue>

	public var count: Int { get { return mValues.count }}

	public init(){
		mValues = []
	}

	public func value(at index: Int) -> CNNativeValue? {
		if 0<=index && index<mValues.count {
			return mValues[index]
		} else {
			return nil
		}
	}

	public func setValue(at index: Int, value val: CNNativeValue) -> Bool {
		if 0<=index && index<mValues.count {
			mValues[index] = val
			return true
		} else {
			return false
		}
	}

	public func appendValue(value val: CNNativeValue) -> Bool {
		mValues.append(val)
		return true
	}

	public func expandElements(target size: Int){
		let diff = size - mValues.count
		if diff > 0 {
			for _ in 0..<diff {
				if !appendValue(value: .nullValue){
					break
				}
			}
		}
	}

	public func forEach(callback: (_ val: CNNativeValue) -> Void){
		for val in mValues {
			callback(val)
		}
	}
}

open class CNNativeValueColumn
{
	private var mTitle:		String?
	private var mColumnIndex:	Int
	private var mTable:		CNNativeValueTable

	public var title: String?	{ get { return mTitle			}}
	public var columnIndex: Int	{ get { return mColumnIndex		}}
	public var count: Int 		{ get { return mTable.numberOfRecords	}}

	public init(title ttl: String?, columnIndex idx: Int, table tbl: CNNativeValueTable){
		mTitle		= ttl
		mColumnIndex	= idx
		mTable		= tbl
	}

	public func value(at index: Int) -> CNNativeValue? {
		if let rec = mTable.record(at: index) {
			return rec.value(at: mColumnIndex)
		}
		return nil
	}

	public func setValue(at index: Int, value val: CNNativeValue) -> Bool {
		if let rec = mTable.record(at: index) {
			return rec.setValue(at: mColumnIndex, value: val)
		}
		return false
	}

	public func forEach(callback: (_ val: CNNativeValue) -> Void){
		mTable.forEachRecord(callback: {
			(_ rec: CNNativeValueRecord) -> Void in
			if let val = rec.value(at: mColumnIndex){
				callback(val)
			} else {
				callback(.nullValue)
			}
		})
	}
}

open class CNNativeValueTable
{
	private var mRecords:		Array<CNNativeValueRecord>
	private var mColumnTitles:	Dictionary<String, Int>
	private var mMaxColumnNum:	Int

	public var numberOfRecords: Int  { get { return mRecords.count	}}
	public var numberOfColumns: Int  { get { return mMaxColumnNum	}}
	public var colmunTitles: Array<String> { get { return Array<String>(mColumnTitles.keys) }}

	public init(){
		mRecords	= []
		mColumnTitles	= [:]
		mMaxColumnNum	= 0
	}

	public func set(columnTitle ttl: String, at idx: Int){
		mColumnTitles[ttl] = idx
	}

	public func columnTitle(at index: Int) -> String? {
		for (str, idx) in mColumnTitles {
			if idx == index {
				return str
			}
		}
		return nil
	}

	public func columnIndex(for title: String) -> Int? {
		return mColumnTitles[title]
	}

	public func record(at idx: Int) -> CNNativeValueRecord? {
		if 0<=idx && idx<mRecords.count {
			return mRecords[idx]
		} else {
			return nil
		}
	}

	public func setRecord(at idx: Int, record rec: CNNativeValueRecord) -> Bool {
		if 0<=idx && idx<mRecords.count {
			mRecords[idx]	= rec
			mMaxColumnNum	= max(mMaxColumnNum, rec.count)
			return true
		} else {
			return false
		}
	}

	public func appendRecord(record rec: CNNativeValueRecord) -> Bool {
		mRecords.append(rec)
		mMaxColumnNum = max(mMaxColumnNum, rec.count)
		return true
	}

	public func expand(horizontalSize hsize: Int, verticalSize vsize: Int){
		/* Append records */
		let vdiff = vsize - mRecords.count
		if vdiff > 0 {
			for _ in 0..<vdiff {
				let newrec = CNNativeValueRecord()
				if !appendRecord(record: newrec){
					break
				}
			}
		}
		/* Expand target record */
		if vsize > 0 {
			if let rec = record(at: vsize-1) {
				rec.expandElements(target: hsize)
				mMaxColumnNum = max(mMaxColumnNum, hsize)
			} else {
				NSLog("[Error] Can not happen at \(#function)")
			}
		}
	}

	public func forEachRecord(callback: (_ rec: CNNativeValueRecord) -> Void){
		for rec in mRecords {
			callback(rec)
		}
	}

	public func column(at colidx: Int) -> CNNativeValueColumn? {
		if 0<=colidx && colidx<mMaxColumnNum {
			let ttl = columnTitle(at: colidx)
			return CNNativeValueColumn(title: ttl, columnIndex: colidx, table: self)
		} else {
			return nil
		}
	}

	public func forEachColumn(callback: (_ rec: CNNativeValueColumn) -> Void){
		for colidx in 0..<mMaxColumnNum {
			let ttl = columnTitle(at: colidx)
			let newcol = CNNativeValueColumn(title: ttl, columnIndex: colidx, table: self)
			callback(newcol)
		}
	}
}
