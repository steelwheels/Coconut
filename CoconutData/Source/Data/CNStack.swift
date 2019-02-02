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

	public func push(_ data: T){
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

	public func pop() -> T? {
		if mArray.count > 0 {
			return mArray.popLast()
		} else {
			return nil
		}
	}
}

