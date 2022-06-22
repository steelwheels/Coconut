/**
 * @file	CNStorageDictionary.swift
 * @brief	Define CNStorageDictionary class
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public class CNStorageDictionary
{
	private var mPath:	CNValuePath
	private var mStorage:	CNStorage

	public init(path pth: CNValuePath, storage strg: CNStorage) {
		mPath		= pth
		mStorage	= strg
	}

	public func value(forKey key: String) -> CNValue? {
		if let dict = getDictionaryValue() {
			return dict[key]
		} else {
			return nil
		}
	}

	public func set(value src: CNValue, forKey key: String) -> Bool {
		if let dict = getDictionaryValue() {
			var mdict = dict ; mdict[key] = src
			return setDictionaryValue(value: mdict)
		} else {
			return false
		}
	}

	private func getDictionaryValue() -> Dictionary<String, CNValue>? {
		if let val = mStorage.value(forPath: mPath) {
			switch val {
			case .dictionaryValue(let dict):
				return dict
			default:
				CNLog(logLevel: .error, message: "Dictionary required on storage", atFunction: #function, inFile: #file)
			}
		}
		return nil
	}

	private func setDictionaryValue(value val: Dictionary<String, CNValue>) -> Bool {
		return mStorage.set(value: .dictionaryValue(val), forPath: mPath)
	}
}

