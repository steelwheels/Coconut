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

	public func execute(operations ops: Array<CNOperation>, timeLimit limitp: TimeInterval?) -> Bool {
		/* Check the operation queue is busy */
		guard limitp == nil || operationsFinished(operations: ops) else {
			return false
		}

		/* Add all operations into the queue */
		mOperationQueue.addOperations(ops, waitUntilFinished: false)

		if let limit = limitp {
			/* Limit the execution time */
			DispatchQueue.main.asyncAfter(deadline: .now() + limit) {
				[weak self] () -> Void in
				if let myself = self {
					if !myself.operationsFinished(operations: ops) {
						myself.cancelOperations(operations: ops)
					}
				}
			}
		}
		//waitOperations()
		return true
	}

	private func operationsFinished(operations ops: Array<CNOperation>) -> Bool {
		for op in ops {
			if op.isExecuting {
				return false
			}
		}
		return true
	}

	private func cancelOperations(operations ops: Array<CNOperation>) {
		for op in ops {
			if op.isExecuting {
				op.cancel()
			}
		}
	}

	public func waitOperations() {
		mOperationQueue.waitUntilAllOperationsAreFinished()
	}
}

