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
	}

	public var count: Int { get {
		if let arr = getSetValue() {
			return arr.count
		} else {
			return 0
		}
	}}

	public func value(forKey key: String, at index: Int) -> CNValue? {
		if let arr = getSetValue() {
			if 0<=index && index<arr.count {
				return arr[index]
			}
		}
		return nil
	}

	public func insert(value src: CNValue) -> Bool {
		if let arr = getSetValue() {
			var marr = arr
			CNValueSet.insert(target: &marr, element: src)
			return setSetValue(value: marr)
		} else {
			return false
		}
	}

	private func getSetValue() -> Array<CNValue>? {
		if let val = mStorage.value(forPath: mPath) {
			switch val {
			case .setValue(let arr):
				return arr
			default:
				CNLog(logLevel: .error, message: "Array required on storage", atFunction: #function, inFile: #file)
			}
		}
		return nil
	}

	private func setSetValue(value val: Array<CNValue>) -> Bool {
		return mStorage.set(value: .setValue(val), forPath: mPath)
	}
}


