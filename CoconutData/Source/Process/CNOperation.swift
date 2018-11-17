/**
 * @file	CNOperation.swift
 * @brief	Define CNOperation class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

open class CNOperation: Operation
{
	private static let isExecutingItem	= "isExecuting"
	private static let isFinishedItem	= "isFinished"
	private static let isCanceledItem	= "isCanceled"

	@objc private dynamic var mIsExecuting:	Bool
	@objc private dynamic var mIsFinished:	Bool
	@objc private dynamic var mIsCanceled:	Bool

	public override init() {
		mIsExecuting	= false
		mIsFinished	= false
		mIsCanceled	= false
		super.init()
	}

	public func reset(){
		mIsExecuting	= false
		mIsFinished	= false
		mIsCanceled	= false
	}

	open override var isExecuting: Bool {
		get {
			return mIsExecuting
		}
		set(val) {
			if val != mIsExecuting {
				willChangeValue(forKey: CNOperation.isExecutingItem)
				mIsExecuting = val
				didChangeValue(forKey: CNOperation.isExecutingItem)
			}
		}
	}

	open override var isFinished: Bool {
		get {
			return mIsFinished
		}
		set(val) {
			if val != mIsFinished {
				willChangeValue(forKey: CNOperation.isFinishedItem)
				mIsFinished = val
				didChangeValue(forKey: CNOperation.isFinishedItem)
			}
		}
	}

	open override var isCancelled: Bool {
		get {
			return mIsCanceled
		}
		set(val){
			if val != mIsCanceled {
				willChangeValue(forKey: CNOperation.isCanceledItem)
				mIsCanceled = val
				didChangeValue(forKey: CNOperation.isCanceledItem)
			}
		}
	}

	open override func main() {
		isExecuting	= true
		isFinished	= false

		if !isCancelled {
			mainOperation()
		}

		isExecuting	= false
		isFinished	= true
	}

	open override func cancel() {
		isCancelled = true
		super.cancel()
	}

	open func mainOperation() -> Void {
		/* Do nothing */
	}
}

