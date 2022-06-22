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
	}

	public var count: Int { get {
		if let arr = getArrayValue() {
			return arr.count
		} else {
			return 0
		}
	}}

	public func value(forKey key: String, at index: Int) -> CNValue? {
		if let arr = getArrayValue() {
			if 0<=index && index<arr.count {
				return arr[index]
			}
		}
		return nil
	}

	public func set(value src: CNValue, at index: Int) -> Bool {
		if let arr = getArrayValue() {
			if 0<=index && index<arr.count {
				var marr = arr
				marr[index] = src
				return setArrayValue(value: marr)
			} else if index == arr.count {
				var marr = arr
				marr.append(src)
				return setArrayValue(value: marr)
			}
		}
		return false
	}

	public func append(value src: CNValue) -> Bool {
		if let arr = getArrayValue() {
			var marr = arr
			marr.append(src)
			return setArrayValue(value: marr)
		} else {
			return false
		}
	}

	private func getArrayValue() -> Array<CNValue>? {
		if let val = mStorage.value(forPath: mPath) {
			switch val {
			case .arrayValue(let arr):
				return arr
			default:
				CNLog(logLevel: .error, message: "Array required on storage", atFunction: #function, inFile: #file)
			}
		}
		return nil
	}

	private func setArrayValue(value val: Array<CNValue>) -> Bool {
		return mStorage.set(value: .arrayValue(val), forPath: mPath)
	}
}


