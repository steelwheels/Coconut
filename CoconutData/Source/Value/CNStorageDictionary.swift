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
		if let val = mStorage.value(forPath: mPath) {
			switch val {
			case .dictionaryValue(let dict):
				return dict[key]
			default:
				CNLog(logLevel: .error, message: "Dictionary required on storage", atFunction: #function, inFile: #file)
				break
			}
		}
		return nil
	}

	public func set(value src: CNValue, forKey key: String) -> Bool {
		var result = false
		if let val = mStorage.value(forPath: mPath) {
			switch val {
			case .dictionaryValue(var dict):
				dict[key] = src	// update value
				result = mStorage.set(value: .dictionaryValue(dict), forPath: mPath)
			default:
				CNLog(logLevel: .error, message: "Dictionary required on storage", atFunction: #function, inFile: #file)
			}
		}
		return result
	}
}

