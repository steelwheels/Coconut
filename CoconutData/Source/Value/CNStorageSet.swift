/**
 * @file	CNStorageSet.swift
 * @brief	Define CNStorageSet class
 * @par Copyright
 *   Copyright (C)  2022 Steel Wheels Project
 */

import Foundation

public class CNStorageSet
{
	private var mPath:	CNValuePath
	private var mStorage:	CNStorage

	public init(path pth: CNValuePath, storage strg: CNStorage) {
		mPath		= pth
		mStorage	= strg
		let _ = getSetValue()
	}

	public var count: Int { get {
		if let arr = getSetValue() {
			return arr.count
		} else {
			return 0
		}
	}}

	public var values: Array<CNValue> { get {
		if let arr = getSetValue() {
			return arr
		} else {
			return []
		}
	}}

	public func value(at index: Int) -> CNValue? {
		return mStorage.value(forPath: indexPath(index: index))
	}

	public func insert(value src: CNValue) -> Bool {
		return mStorage.append(value: src, forPath: mPath)
	}

	private func getSetValue() -> Array<CNValue>? {
		if let val = mStorage.value(forPath: mPath) {
			switch val {
			case .dictionaryValue(let dict):
				if let vals = dict["values"] {
					return vals.toArray()
				}
			default:
				break
			}
		}
		CNLog(logLevel: .error, message: "Set required on storage", atFunction: #function, inFile: #file)
		return nil
	}

	private func indexPath(index idx: Int) -> CNValuePath {
		return CNValuePath(path: mPath, subPath: [.index(idx)])
	}
}


