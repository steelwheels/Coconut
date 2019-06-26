/**
 * @file	CNOperationQueue.swift
 * @brief	Define CNOperationQueue class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

open class CNOperationQueue
{
	private var mOperationQueue:	OperationQueue

	public init(){
		mOperationQueue = OperationQueue()
	}

	public var operationCount: Int {
		get {
			return mOperationQueue.operationCount
		}
	}

	public func execute(operations ctxts: Array<CNOperationContext>, timeLimit limitp: TimeInterval?) -> Array<CNOperationContext> {
		var nonexecs: Array<CNOperationContext> = []

		/* Add all operations into the queue */
		var execs: Array<CNOperationExecutor> = []
		for ctxt in ctxts {
			/* Set finalOperation which is called at the end of operation */
			if !ctxt.isExecuting {
				let exec = CNOperationExecutor(context: ctxt)
				execs.append(exec)
			} else {
				nonexecs.append(ctxt)
			}
		}
		mOperationQueue.addOperations(execs, waitUntilFinished: false)

		if let limit = limitp {
			/* Limit the execution time */
			DispatchQueue.main.asyncAfter(deadline: .now() + limit) {
				() -> Void in
				for exec in execs {
					if exec.context.isExecuting {
						nonexecs.append(exec.context)
						exec.cancel()
					}
				}
			}
		}
		//waitOperations()
		return nonexecs
	}

	public func waitOperations() {
		mOperationQueue.waitUntilAllOperationsAreFinished()
	}
}

