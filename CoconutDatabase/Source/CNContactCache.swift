/**
 * @file	CNContactCache.swift
 * @brief	Define CNContactCache class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import CoconutData
import Foundation

/*
public class CNContactCache: CNCacheOperation
{
	private var mCacheTable: 	Dictionary<Int, Bool>
	private var mNextCacheId: 	Int

	public init(){
		mCacheTable  	= [:]
		mNextCacheId	= 0
	}

	public func add() -> Int {
		let cid = mNextCacheId
		mCacheTable[cid] = false
		mNextCacheId += 1
		return cid
	}

	public func remove(cacheId cid: Int) {
		mCacheTable[cid] = nil
	}

	public func setDirty() {
		for cid in mCacheTable.keys {
			mCacheTable[cid] = true
		}
	}

	public func isDirty(cacheId cid: Int) -> Bool {
		if let val = mCacheTable[cid] {
			return val
		} else {
			CNLog(logLevel: .error, message: "Unknown cache id: \(cid)", atFunction: #function, inFile: #file)
			return false
		}
	}

	public func setClean(cacheId cid: Int) {
		mCacheTable[cid] = false
	}
}
*/

