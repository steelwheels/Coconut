/**
 * @file	CNQueue.swift
 * @brief	Define CNQueue class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

private let CHUNK_SIZE:		Int = 64

public class CNQueue<T>
{
	private var mArray: 		Array<T>
	private var mFirstValidIndex:	Int
	private var mNextStoreIndex:	Int

	public init(){
		mArray 			= []
		mFirstValidIndex	= -1
		mNextStoreIndex		= 0
	}

	public var count: Int {
		get {
			if mFirstValidIndex >= 0 {
				return mNextStoreIndex - mFirstValidIndex
			} else {
				return 0
			}
		}
	}

	open func push(_ data: T){
		if mNextStoreIndex < mArray.count {
			mArray[mNextStoreIndex] = data
		} else {
			mArray.append(data)
		}
		mNextStoreIndex += 1
		if mFirstValidIndex < 0 {
			mFirstValidIndex = 0
		}
	}

	public func peek() -> T? {
		if mFirstValidIndex >= 0 && mFirstValidIndex < mNextStoreIndex {
			return mArray[mFirstValidIndex]
		} else {
			return nil
		}
	}

	open func pop() -> T? {
		if mFirstValidIndex >= 0 && mFirstValidIndex < mNextStoreIndex {
			let data = mArray[mFirstValidIndex]
			mFirstValidIndex += 1
			reduceSize()
			return data
		} else {
			return nil
		}
	}

	private func reduceSize() {
		if CHUNK_SIZE <= mFirstValidIndex && mFirstValidIndex < mNextStoreIndex {
			for i in mFirstValidIndex..<mNextStoreIndex {
				mArray[i - CHUNK_SIZE] = mArray[i]
			}
			mFirstValidIndex -= CHUNK_SIZE
			mNextStoreIndex  -= CHUNK_SIZE
		}
	}

	public func clear() {
		mArray 			= []
		mFirstValidIndex	= -1
		mNextStoreIndex		= 0
	}

	public func peekAll() -> Array<T> {
		if mFirstValidIndex >= 0 && mFirstValidIndex < mNextStoreIndex {
			var result: Array<T> = []
			for i in mFirstValidIndex..<mNextStoreIndex {
				result.append(mArray[i])
			}
			return result
		} else {
			return []
		}
	}

	/* For debugging */
	public func dumpState(console cons: CNConsole) {
		cons.print(string: "{1st:\(mFirstValidIndex), next:\(mNextStoreIndex), count:\(mArray.count) }\n")
		let array = peekAll()
		cons.print(string: "[")
		for elm in array {
			cons.print(string: "\(elm) ")
		}
		cons.print(string: "]\n")
	}
}


