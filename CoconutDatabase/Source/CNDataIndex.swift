/**
 * @file	CNDataIndex.swift
 * @brief	Define CNDataIndex class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public struct CNDataIndex: Comparable, Hashable
{
	public var index:	Int 	// row index
	public var property:	String	// property name in record

	public init() {
		index 		= 0
		property	= "?"
	}

	public static func < (lhs: CNDataIndex, rhs: CNDataIndex) -> Bool {
		if lhs.index < rhs.index {
			return lhs.property < rhs.property
		} else {
			return false
		}
	}

	public static func == (lhs: CNDataIndex, rhs: CNDataIndex) -> Bool {
		return (lhs.index == rhs.index) && (lhs.property == rhs.property)
	}
}

private class CNDataListner
{
	public typealias ListnerFunction = (_ val: CNNativeValue) -> Void

	private var mListners:	Dictionary<Int, ListnerFunction>
	private var mUniqueId:	Int

	public var listners: Array<ListnerFunction> {
		get { return Array(mListners.values) }
	}

	public init() {
		mListners	= [:]
		mUniqueId	= 0
	}

	public func addListner(_ lfunc: @escaping ListnerFunction) -> Int {
		let uid = mUniqueId
		mListners[uid] = lfunc
		mUniqueId += 1
		return uid
	}

	public func removeListner(listnerId lid: Int) {
		if let _ = mListners[lid] {
			mListners[lid] = nil
		} else {
			CNLog(logLevel: .error, message: "Failed to remove", atFunction: #function, inFile: #file)
		}
	}
}

public class CNDataListners
{
	public typealias ListnerFunction = (_ val: CNNativeValue) -> Void

	private var mListners:	Dictionary<CNDataIndex, CNDataListner>

	public init() {
		mListners = [:]
	}

	public func listners(index idx: CNDataIndex) -> Array<ListnerFunction> {
		if let listner = mListners[idx] {
			return listner.listners
		} else {
			return []
		}
	}

	public func addListner(index idx: CNDataIndex, listner lfunc: @escaping ListnerFunction) -> Int {
		if let listner = mListners[idx] {
			return listner.addListner(lfunc)
		} else {
			let listner = CNDataListner()
			mListners[idx] = listner
			return listner.addListner(lfunc)
		}
	}

	public func removeListner(index idx: CNDataIndex, listnerId lid: Int){
		if let listner = mListners[idx] {
			listner.removeListner(listnerId: lid)
		} else {
			CNLog(logLevel: .error, message: "Failed to remove", atFunction: #function, inFile: #file)
		}
	}
}
