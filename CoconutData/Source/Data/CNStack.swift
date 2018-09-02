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

	public func push(_ data: T){
		mArray.append(data)
	}

	public func pop() -> T? {
		if mArray.count > 0 {
			return mArray.popLast()
		} else {
			return nil
		}
	}
}

