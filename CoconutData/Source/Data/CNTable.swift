/**
 * @file	CNTable.swift
 * @brief	Define CNTable protocol
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public enum CNTableLoadResult {
	case ok
	case error(NSError)
}

public enum CNTableEvent {
	case addRecord(Int)		// added row index
}



public protocol CNTable
{
	var recordCount: Int { get }

	var allFieldNames:    Array<String> { get }
	func fieldName(at index: Int) -> String?

	func newRecord() -> CNRecord
	func record(at row: Int) -> CNRecord?
	func search(value val: CNValue, forField field: String) -> Array<CNRecord>
	func append(record rcd: CNRecord)
	func forEach(callback cbfunc: (_ record: CNRecord) -> Void)

	func sort(byDescriptors descs: CNSortDescriptors)

	func addListner(listner lnr: @escaping CNTableListener.ListenerFunction) -> Int
	func removeListner(listnerId lid: Int)
}

public class CNTableListener
{
	public typealias ListenerFunction = (_ events: Array<CNTableEvent>) -> Void	// new-value

	private var mListnerFunctions:	Dictionary<Int, ListenerFunction>
	private var mListnerId:		Int

	public init(){
		mListnerFunctions	= [:]
		mListnerId		= 0
	}

	public var count: Int { get {
		return mListnerFunctions.count
	}}

	public func add(listenerFunction lfunc: @escaping ListenerFunction) -> Int {
		let lid = mListnerId
		mListnerFunctions[lid] = lfunc
		mListnerId += 1
		return lid
	}

	public func remove(listnerId lid: Int) {
		mListnerFunctions[lid] = nil
	}

	public func sendEvents(events evts: Array<CNTableEvent>) {
		let cbfuncs = mListnerFunctions.values
		for cbfunc in cbfuncs {
			cbfunc(evts)
		}
	}
}


