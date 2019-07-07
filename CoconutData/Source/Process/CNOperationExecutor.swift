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
			/* Start time */
			let starttime = Date()

			/* Execute main operation */
			mContext.main()

			/* Get execution time */
			mContext.executionCount	    += 1
			mContext.totalExecutionTime += Date().timeIntervalSince(starttime)
		}

		mContext.isFinished	= true
		mContext.isExecuting	= false
	}

	open override func cancel() {
		mContext.isCancelled = true
		super.cancel()
	}
}

