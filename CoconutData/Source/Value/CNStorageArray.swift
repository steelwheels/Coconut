/**
 * @file	CNStorageArray.swift
 * @brief	Define CNStorageArray class
 * @par Copyright
 *   Copyright (C)  2022 Steel Wheels Project
 */

import Foundation

public class CNStorageArray
{
	private var mPath:	CNValuePath
	private var mStorage:	CNStorage

	public init(path pth: CNValuePath, storage strg: CNStorage) {
		mPath		= pth
		mStorage	= strg

		/* Check */
		let _ = getArrayValue()
	}

	public var count: Int { get {
		if let arr = getArrayValue() {
			return arr.count
		} else {
			return 0
		}
	}}

	public var values: Array<CNValue> { get {
		if let arr = getArrayValue() {
			return arr
		} else {
			return []
		}
	}}

	public func value(at index: Int) -> CNValue? {
		return mStorage.value(forPath: indexPath(index: index))
	}

	public func set(value src: CNValue, at index: Int) -> Bool {
		return mStorage.set(value: src, forPath: indexPath(index: index))
	}

	public func append(value src: CNValue) -> Bool {
		return mStorage.append(value: src, forPath: mPath)
	}

	private func indexPath(index idx: Int) -> CNValuePath {
		return CNValuePath(path: mPath, subPath: [.index(idx)])
	}

	private func getArrayValue() -> Array<CNValue>? {
		if let val = mStorage.value(forPath: mPath) {
			switch val {
			case .arrayValue(let arr):
				return arr
			default:
				break
			}
		}
		CNLog(logLevel: .error, message: "Not array value", atFunction: #function, inFile: #file)
		return nil
	}
}


