/**
 * @file	CNStorageArray.swift
 * @brief	Define CNStorageArray class
 * @par Copyright
 *   Copyright (C)  2022 Steel Wheels Project
 */

import Foundation

public protocol CNArray
{
	var count: Int { get }
	var values: Array<CNValue> { get }

	func value(at index: Int) -> CNValue?
	func contains(value src: CNValue) -> Bool

	func set(value src: CNValue, at index: Int) -> Bool
	func append(value src: CNValue) -> Bool
}

public class CNStorageArray: CNArray
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

	public func contains(value src: CNValue) -> Bool {
		if let vals = getArrayValue() {
			for val in vals {
				switch CNCompareValue(value0: src, value1: val) {
				case .orderedAscending:	// src < val[x]
					break	// continue
				case .orderedSame:	// src == vals[x]
					return true
				case .orderedDescending:
					break	// contibue
				}
			}
		}
		return false
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


