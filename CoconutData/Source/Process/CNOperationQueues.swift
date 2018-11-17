/**
 * @file	CNOperationQueues.swift
 * @brief	Define CNOperationQueues class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public class CNOperationQueues
{
	private var		mQueueNum:		Int
	private var		mOperationQueues:	Array<OperationQueue>

	public init(queueNum num: Int){
		mQueueNum	 = num
		mOperationQueues = []
		for _ in 0..<num {
			mOperationQueues.append(OperationQueue())
		}
	}

	@objc private dynamic var mAlreadyDone: Bool = false

	public func execute(operationGroups groups: Array<Array<CNOperation>>, timeLimit limit: TimeInterval?) {
		/* add all operations to queue */
		guard groups.count <= mQueueNum else {
			NSLog("[Error] Invalid parameter num \(groups.count) at \(#function)")
			return
		}

		for i in 0..<groups.count {
			let queue = mOperationQueues[i]
			for op in groups[i] {
				queue.addOperation(op)
			}
		}

		mAlreadyDone = false
		if let limit = limit {
			/* Limit the execution time */
			DispatchQueue.main.asyncAfter(deadline: .now() + limit) {
				if !self.mAlreadyDone {
					if !self.mAlreadyDone {
						self.cancelOperations(operationGroups: groups)
					}
				}
			}
		}
		waitOperations()
		mAlreadyDone = true
	}

	private func cancelOperations(operationGroups groups: Array<Array<CNOperation>>) {
		for group in groups {
			for op in group {
				if op.isExecuting {
					op.cancel()
				}
			}
		}
	}

	private func waitOperations() {
		for queue in mOperationQueues {
			queue.waitUntilAllOperationsAreFinished()
		}
	}
}

