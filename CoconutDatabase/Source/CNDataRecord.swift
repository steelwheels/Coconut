/**
 * @file	CNDataRecord.swift
 * @brief	Define CNDataRecord class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public class CNDataRecord
{
	private var mDataArray:	Array<CNNativeValue>

	public init(fieldCount count: Int){
		mDataArray = Array(repeating: .nullValue, count: count)
	}

	public func setField(index idx: Int, value val: CNNativeValue){
		if 0<=idx && idx<mDataArray.count {
			mDataArray[idx] = val
		}
	}
	public func field(index idx: Int) -> CNNativeValue? {
		if 0<=idx && idx<mDataArray.count {
			return mDataArray[idx]
		} else {
			return nil
		}
	}
}


