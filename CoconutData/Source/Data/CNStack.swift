/**
 * @file	CNStack.swift
 * @brief	Define CNStack class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNStack<T>
{
	private var mArray: Array<T>

	public init(){
		mArray = []
	}

	public var count: Int {
		get { return mArray.count }
	}

	open func push(_ data: T){
		mArray.append(data)
	}

	public func peek() -> T? {
		let cnt = mArray.count
		if cnt > 0 {
			return mArray[cnt-1]
		} else {
			return nil
		}
	}

	open func pop() -> T? {
		if mArray.count > 0 {
			return mArray.popLast()
		} else {
			return nil
		}
	}

	public func peekAll(doReverseOrder dorev: Bool) -> Array<T> {
		if dorev {
			return mArray.reversed()
		} else {
			return mArray
		}
	}
}

public class CNMutexStack<T>: CNStack<T>
{
	private var mLock:	NSLock

	public override init(){
		mLock = NSLock()
		super.init()
	}

	open override func push(_ data: T){
		mLock.lock()
		  super.push(data)
		mLock.unlock()
	}

	open override func pop() -> T? {
		let result: T?
		mLock.lock()
		  result = super.pop()
		mLock.unlock()
		return result
	}
}
