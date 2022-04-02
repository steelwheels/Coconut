/*
 * @file	CNValueCache.swift
 * @brief	Define CNValueCache class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

private class CacheInfo {
	private var	mPath:		CNValuePath
	private var 	mIsDirty:	Bool

	public var path: CNValuePath { get { return mPath }}

	public var isDirty: Bool {
		get         { return mIsDirty }
		set(newval) { mIsDirty = newval }
	}

	public init(path p: CNValuePath){
		mPath		= p
		mIsDirty	= true
	}
}

public class CNValueCache: CNTableCache
{
	private var mCacheTable: Dictionary<Int, CacheInfo>
	private var mCacheId:    Int
	private var mLock:	 NSLock

	public init(){
		mCacheTable = [:]
		mCacheId    = 0
		mLock	    = NSLock()
	}

	public func add(accessor path: CNValuePath) -> Int {
		mLock.lock() ; defer { mLock.unlock() }
		let curid = mCacheId
		mCacheTable[curid] = CacheInfo(path: path)
		mCacheId += 1
		return curid
	}

	public func remove(cacheId cid: Int){
		mLock.lock() ; defer { mLock.unlock() }
		mCacheTable[cid] = nil
	}

	public func isDirty(cacheId cid: Int) -> Bool {
		mLock.lock() ; defer { mLock.unlock() }
		if let info = mCacheTable[cid] {
			return info.isDirty
		} else {
			CNLog(logLevel: .error, message: "Unknown accessor: \(cid)", atFunction: #function, inFile: #file)
			return true
		}
	}

	public func setDirty(at path: CNValuePath) {
		mLock.lock() ; defer { mLock.unlock() }
		for info in mCacheTable.values {
			if info.path.isIncluded(in: path) {
				info.isDirty = true
			}
		}
	}

	public func setClean(cacheId cid: Int) {
		mLock.lock() ; defer { mLock.unlock() }
		if let info = mCacheTable[cid] {
			info.isDirty = false
		} else {
			CNLog(logLevel: .error, message: "Unknown accessor: \(cid)", atFunction: #function, inFile: #file)
		}
	}
}

