/**
 * @file	CNArrayStream.swift
 * @brief	Define CNArrayStream class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public class CNArrayStream<T>
{
	private var mArray	: Array<T>
	private var mIndex	: Int

	public init(){
		mArray		= []
		mIndex		= 0
	}

	public init(source src: Array<T>){
		mArray		= src
		mIndex		= 0
	}

	public func get() -> T? {
		if mIndex < mArray.count {
			let result = mArray[mIndex]
			mIndex += 1
			return result
		} else {
			return nil
		}
	}

	public func get(count cnt: Int) -> Array<T> {
		var result: Array<T> = []
		for _ in 0..<cnt {
			if let d = get() {
				result.append(d)
			} else {
				break
			}
		}
		return result
	}

	public func unget() -> T? {
		if mIndex > 0 {
			mIndex -= 1
			let result = mArray[mIndex]
			return result
		} else {
			return nil
		}
	}

	public func peek(offset ofst: Int) -> T? {
		let idx = mIndex + ofst
		if 0<=idx && idx < mArray.count {
			return mArray[idx]
		} else {
			return nil
		}
	}

	public func isEmpty() -> Bool {
		if mIndex < mArray.count {
			return false
		} else {
			return true
		}
	}

	public func append(item newitem: T){
		mArray.append(newitem)
	}

	public func trace(trace trc: (_ src: T) -> Bool) -> Array<T> {
		var result: Array<T> = []
		var newidx: Int = mIndex
		for i in mIndex..<mArray.count {
			let elm = mArray[i]
			if trc(elm) {
				result.append(elm)
				newidx = i + 1
			} else {
				break
			}
		}
		mIndex = newidx
		return result
	}

	public var description: String {
		return "Array[\(mIndex)/\(mArray.count)]"
	}
}

