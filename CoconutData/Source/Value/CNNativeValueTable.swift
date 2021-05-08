/**
 * @file	CNNaviveValueTable.swift
 * @brief	Define CNNativeValueTable class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNNativeValueColumn
{
	private var mTitle:	String?
	private var mRows:	Array<CNNativeValue>

	public var title: String? {
		get		{ return mTitle }
		set(newval)	{ mTitle = newval }
	}

	public var count: Int { get { return mRows.count }}

	public init(){
		mTitle	= nil
		mRows	= []
	}

	public func value(index idx: Int) -> CNNativeValue? {
		if 0<=idx && idx<mRows.count {
			return mRows[idx]
		} else{
			return nil
		}
	}

	public func forEach(_ cbfunc: (_ val: CNNativeValue) -> Void) {
		for val in mRows {
			cbfunc(val)
		}
	}

	public func setValue(index idx: Int, value val: CNNativeValue){
		if 0<=idx && idx<mRows.count {
			mRows[idx] = val ;
		} else {
			NSLog("[Error] Out of range at \(#file)")
		}
	}

	public func appendValue(value val: CNNativeValue){
		mRows.append(val)
	}
}

public class CNNativeValueTable
{
	private var mColumns:	Array<CNNativeValueColumn>

	public var columnCount: Int {
		get { return mColumns.count }
	}

	public var rowCount: Int { get {
		if mColumns.count > 0 {
			return mColumns[0].count
		} else {
			return 0
		}
	}}

	public init(){
		mColumns = []
	}

	public func column(index idx: Int) -> CNNativeValueColumn? {
		if 0<=idx && idx<mColumns.count {
			return mColumns[idx]
		} else {
			return nil
		}
	}

	public func forEach(_ cbfunc: (_ val: CNNativeValueColumn) -> Void) {
		for column in mColumns {
			cbfunc(column)
		}
	}

	public func setColumn(index idx: Int, column col: CNNativeValueColumn){
		if 0<=idx && idx<mColumns.count {
			mColumns[idx] = col
		} else {
			NSLog("[Error] Out of range at \(#file)")
		}
	}

	public func appendColumn(column col: CNNativeValueColumn){
		mColumns.append(col)
	}
}

