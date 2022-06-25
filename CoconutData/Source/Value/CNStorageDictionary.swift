/**
 * @file	CNStorageDictionary.swift
 * @brief	Define CNStorageDictionary class
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public protocol CNDictionary
{
	var count:  Int            { get }
	var values: Array<CNValue> { get }
	var keys:   Array<String>  { get }

	func value(forKey key: String) -> CNValue?
	func set(value val: CNValue, forKey key: String) -> Bool
}

public class CNStorageDictionary: CNDictionary
{
	private var mPath:	CNValuePath
	private var mStorage:	CNStorage

	public init(path pth: CNValuePath, storage strg: CNStorage) {
		mPath		= pth
		mStorage	= strg

		let _ = getDictionaryValue()
	}

	public var count: Int { get {
		if let dict = getDictionaryValue() {
			return dict.count
		} else {
			return 0
		}
	}}

	public var values: Array<CNValue> { get {
		if let dict = getDictionaryValue() {
			return Array(dict.values)
		} else {
			return []
		}
	}}

	public var keys: Array<String> { get {
		if let dict = getDictionaryValue() {
			return Array(dict.keys)
		} else {
			return []
		}
	}}

	public func value(forKey key: String) -> CNValue? {
		return mStorage.value(forPath: memberPath(member: key))
	}

	public func set(value src: CNValue, forKey key: String) -> Bool {
		return mStorage.set(value: src, forPath: memberPath(member: key))
	}

	private func getDictionaryValue() -> Dictionary<String, CNValue>? {
		if let val = mStorage.value(forPath: mPath) {
			switch val {
			case .dictionaryValue(let dict):
				return dict
			default:
				break
			}
		}
		CNLog(logLevel: .error, message: "Dictionary required on storage", atFunction: #function, inFile: #file)
		return nil
	}

	private func memberPath(member memb: String) -> CNValuePath {
		return CNValuePath(path: mPath, subPath: [.member(memb)])
	}
}

