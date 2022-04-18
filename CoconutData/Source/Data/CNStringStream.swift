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
	private var mCurrentIndex:	String.Index

	public required init(string src: String){
		mString		= src
		mCurrentIndex	= src.startIndex
	}

	public func getc() -> Character? {
		if mCurrentIndex < mString.endIndex {
			let c: Character = mString[mCurrentIndex]
			mCurrentIndex = mString.index(after: mCurrentIndex)
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

	public func geti() -> Int? {
		var intstr: String = ""
		var docont = true
		while docont {
			if let c = self.getc() {
				if c.isNumber {
					intstr.append(c)
				} else {
					let _ = ungetc()
					docont = false
				}
			} else {
				docont = false
			}
		}
		return intstr.count > 0 ? Int(intstr) : nil
	}

	public func ungetc() -> Character? {
		if mString.startIndex < mCurrentIndex {
			mCurrentIndex = mString.index(before: mCurrentIndex)
			return mString[mCurrentIndex]
		} else {
			return nil
		}
	}

	public func peek(offset ofst: Int) -> Character? {
		var idx = mCurrentIndex
		for _ in 0..<ofst {
			if idx < mString.endIndex {
				idx = mString.index(after: idx)
			} else {
				break
			}
		}
		return idx < mString.endIndex ? mString[idx] : nil
	}

	public func skip(count cnt: Int){
		for _ in 0..<cnt {
			if getc() == nil {
				break
			}
		}
	}

	public func skipSpaces() {
		while let c = getc() {
			if !c.isWhitespace {
				let _ = self.ungetc()
				return
			}
		}
	}

	public func isEmpty() -> Bool {
		if mCurrentIndex < mString.endIndex {
			return false
		} else {
			return true
		}
	}

	public func splitByFirstCharacter(characters chars: Array<Character>) -> (CNStringStream, CNStringStream)? {
		var currentidx = mCurrentIndex
		while currentidx < mString.endIndex {
			let c: Character = mString[currentidx]
			for targ in chars {
				if targ == c {
					let nextidx = mString.index(after: currentidx)
					let stra    = String(mString[mCurrentIndex..<currentidx])
					let strb    = String(mString[nextidx..<mString.endIndex])
					return (CNStringStream(string: stra), CNStringStream(string: strb))
				}
			}
			currentidx = mString.index(after: currentidx)
		}
		return nil
	}

	public func toString() -> String? {
		if mCurrentIndex < mString.endIndex {
			return String(mString[mCurrentIndex ..< mString.endIndex])
		} else {
			return nil
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
			let str = String(mString[mCurrentIndex ..< mString.endIndex])
			return "String(\"\(str)\")"
		}
	}
}
