/**
 * @file	CNDatabase.swift
 * @brief	Define CNDatabase class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public protocol CNDatabase
{
	associatedtype RecordType: CNDataRecord

	var recordCount: Int { get }

	func record(at index: Int) -> RecordType?
	func append(record rcd: RecordType)
}

public class CNNativeValueDatabase: CNDatabase
{
	public typealias RecordType = CNNativeValueRecord

	private var mRecords: Array<CNNativeValueRecord>

	public init() {
		mRecords = []
	}

	public var recordCount: Int {
		get { return mRecords.count }
	}

	public func record(at index: Int) -> RecordType? {
		if 0<=index && index<mRecords.count {
			return mRecords[index]
		} else {
			return nil
		}
	}

	public func append(record rcd: RecordType) {
		mRecords.append(rcd)
	}
}

