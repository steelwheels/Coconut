/**
 * @file	CNOperation.swift
 * @brief	Define CNOperation class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

open class CNOperationExecutor: Operation
{
	private var mContext:	CNOperationContext

	public init(context ctxt: CNOperationContext) {
		mContext = ctxt
		super.init()
		mContext.ownerExecutor = self
	}

	deinit {
		mContext.ownerExecutor = nil
	}

	public var context: CNOperationContext {
		get { return mContext }
	}

	open override func main() {
		mContext.isExecuting = true
		mContext.isFinished  = false

		if !mContext.isCancelled {
			mContext.main()
		}

		mContext.isExecuting	= false
		mContext.isFinished	= true
	}

	open override func cancel() {
		mContext.isCancelled = true
		super.cancel()
	}
}

