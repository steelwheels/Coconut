/**
 * @file	UTOperationQueue.swift
 * @brief	Test function for CNOperationQueueclass
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

private class UTOperation: CNOperation
{
	private var mIdentifier:	Int
	private var mSleepTime:		TimeInterval
	private var mConsole:		CNConsole

	public required init(identifier ident: Int, sleepTime stime: TimeInterval, console cons: CNConsole) {
		mIdentifier	= ident
		mSleepTime 	= stime
		mConsole 	= cons
		super.init()

		self.mainFunction = {
			Thread.sleep(forTimeInterval: self.mSleepTime)
		}
	}

	public func printState(){
		//mConsole.print(string: "op[\(mIdentifier)] ... ")
		if self.isCancelled {
			mConsole.print(string: "Canceled\(mIdentifier)\n")
		} else if self.isFinished {
			mConsole.print(string: "Finished\(mIdentifier)\n")
		} else {
			mConsole.print(string: "??\(mIdentifier)\n")
		}
	}
}

public func testOperationQueue(console cons: CNConsole) -> Bool
{
	let queue = CNOperationQueue()

	cons.print(string: "* TEST0\n")
	let ops0 = allocateOperations(sleepTime: 0.0, console: cons)
	checkQueue(state: queue.execute(operations: ops0, timeLimit: nil), console: cons)
	queue.waitOperations()
	printOperations(operations: ops0)
	cons.print(string: "Done (0)\n")

	cons.print(string: "* TEST1\n")
	let ops1 = allocateOperations(sleepTime: 0.0, console: cons)
	checkQueue(state: queue.execute(operations: ops1, timeLimit: 0.1), console: cons)
	queue.waitOperations()
	printOperations(operations: ops1)
	cons.print(string: "Done (1)\n")

	cons.print(string: "* TEST2\n")
	let ops2 = allocateOperations(sleepTime: 1.0, console: cons)
	checkQueue(state: queue.execute(operations: ops2, timeLimit: 0.1), console: cons)
	queue.waitOperations()
	printOperations(operations: ops2)
	cons.print(string: "Done (2)\n")

	return true
}

private func allocateOperations(sleepTime stime: TimeInterval, console cons: CNConsole) -> Array<UTOperation>
{
	var ops: Array<UTOperation> = []
	for i in 0..<2 {
		ops.append(UTOperation(identifier: i, sleepTime: stime, console: cons))
	}
	return ops
}

private func printOperations(operations ops: Array<UTOperation>)
{
	for op in ops {
		op.printState()
	}
}

private func checkQueue(state val: Bool, console cons: CNConsole) {
	if !val {
		cons.error(string: "[Error] Failed to enqueue operation\n")
	}
}


