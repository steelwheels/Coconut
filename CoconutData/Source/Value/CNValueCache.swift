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
	private weak var	mPath:		CNValuePath?
	private var 		mIsDirty:	Bool

	public var path: CNValuePath {
		get {
			if let p = mPath {
				return p
			} else {
				CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
				fatalError("Can not happen")
			}
		}
	}

	public var isDirty: Bool {
		get         { return mIsDirty }
		set(newval) { mIsDirty = newval }
	}

	public init(path p: CNValuePath){
		mPath		= p
		mIsDirty	= true
	}
}

public class CNValueCache
{
	private var mCacheTable: Dictionary<String, CacheInfo>

	public init(){
		mCacheTable = [:]
	}

	public func add(accessor path: CNValuePath){
		mCacheTable[path.expression] = CacheInfo(path: path)
	}

	public func remove(accessor path: CNValuePath){
		mCacheTable[path.expression] = nil
	}

	public func isDirty(accessor path: CNValuePath) -> Bool {
		if let info = mCacheTable[path.expression] {
			return info.isDirty
		} else {
			CNLog(logLevel: .error, message: "Unknown accessor: \(path.expression)", atFunction: #function, inFile: #file)
			return true
		}
	}

	public func setDirty(at path: CNValuePath) {
		for info in mCacheTable.values {
			if info.path.isIncluded(in: path) {
				info.isDirty = true
			}
		}
	}

	public func setClean(accessor path: CNValuePath) {
		if let info = mCacheTable[path.expression] {
			info.isDirty = false
		} else {
			CNLog(logLevel: .error, message: "Unknown accessor: \(path.expression)", atFunction: #function, inFile: #file)
		}
	}

	public func setAllClean(){
		for cache in mCacheTable.values {
			cache.isDirty = false
		}
	}
}

