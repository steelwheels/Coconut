/**
 * @file	CNDataTable.swift
 * @brief	Define CNDataTable class
 * @par Copyright
 *   Copyright (C) 2021Steel Wheels Project
 */

import CoconutData
import Foundation

public class CNDataTable
{
	private var mRecords: Array<CNDataRecord>

	public var records: Array<CNDataRecord> { get { return mRecords }}

	public init(){
		mRecords = []
	}

	public func append(record rec: CNDataRecord){
		mRecords.append(rec)
	}
}

