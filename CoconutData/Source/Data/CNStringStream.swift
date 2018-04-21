/**
 * @file	CNStringStream.swift
 * @brief	Define CNStringStream class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public class CNStringStream
{
	private var mString:		String
	private var mStartIndex:	String.Index
	private var mEndIndex:		String.Index

	public init(string src: String){
		mString		= src
		mStartIndex	= src.startIndex
		mEndIndex	= src.endIndex
	}

	public var count: Int {
		get { return mString.count }
	}

	public func getc() -> Character? {
		if mStartIndex < mEndIndex {
			let c: Character = mString[mStartIndex]
			mStartIndex = mString.index(after: mStartIndex)
			return c
		} else {
			return nil
		}
	}

	public func gets(count cnt: Int) -> String {
		var result: String = ""
		for _ in 0..<cnt {
			if let c = getc() {
				result.append(c)
			} else {
				break
			}
		}
		return result
	}

	public func ungetc() -> Character? {
		if mString.startIndex < mStartIndex {
			mStartIndex = mString.index(before: mStartIndex)
			return mString[mStartIndex]
		} else {
			return nil
		}
	}

	public func peek(offset ofst: Int) -> Character? {
		if mStartIndex < mEndIndex {
			var idx = mStartIndex
			for _ in 0..<ofst {
				idx = mString.index(after: idx)
				if !(idx < mEndIndex) {
					return nil
				}
			}
			return mString[idx]
		} else {
			return nil
		}
	}

	public func skip(count cnt: Int){
		for _ in 0..<cnt {
			if getc() == nil {
				break
			}
		}
	}

	public func isEmpty() -> Bool {
		if mStartIndex < mEndIndex {
			return false
		} else {
			return true
		}
	}

	public func trace(trace trc: (Character) -> Bool) -> String {
		var result: String = ""
		while true {
			if let c = getc() {
				if trc(c) {
					result.append(c)
				} else {
					_ = ungetc()
					return result
				}
			} else {
				return result
			}
		}
	}

	public var description: String {
		get {
			let sidx = mStartIndex.encodedOffset
			let eidx = mEndIndex.encodedOffset
			return "String(\"\(mString)\")[\(sidx):\(eidx)]"
		}
	}
}
