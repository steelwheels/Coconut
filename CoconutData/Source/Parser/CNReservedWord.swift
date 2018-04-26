/**
 * @file	CNResevedWord.swift
 * @brief	Define CNReservedWord class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public struct CNReservedWord
{
	var id	 : Int
	var word : String

	public init(id idnum: Int, word wd: String){
		id   = idnum
		word = wd
	}
}

public class CNReservedWordTable
{
	private var mDictionary : Dictionary<String, Int>

	public init(reservedWords words: Array<CNReservedWord>){
		mDictionary = [:]
		for word in words {
			mDictionary[word.word] = word.id
		}
	}

	public func search(word wd: String) -> Int? {
		return mDictionary[wd]
	}
}
