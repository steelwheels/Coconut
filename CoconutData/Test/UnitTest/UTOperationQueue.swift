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

	public init(identifier ident: Int, sleepTime stime: TimeInterval, console cons: CNConsole) {
		mIdentifier	= ident
		mSleepTime 	= stime
		mConsole 	= cons
	}
	
	public override func mainOperation() {
		mConsole.print(string: "op[\(mIdentifier)]\n")
		Thread.sleep(forTimeInterval: mSleepTime)
	}

	public func printState(){
		mConsole.print(string: "op[\(mIdentifier)] ... ")
		if self.isCancelled {
			mConsole.print(string: "Canceled\n")
		} else if self.isFinished {
			mConsole.print(string: "Finished\n")
		} else {
			mConsole.print(string: "??\n")
		}
	}
}

public func testOperationQueue(console cons: CNConsole) -> Bool
{
	let queues = CNOperationQueues(queueNum: 2)

	cons.print(string: "* TEST0\n")
	let groups0 = allocateOperations(sleepTime: 0.0, console: cons)
	queues.execute(operationGroups: groups0, timeLimit: nil)
	printOperations(operationGroups: groups0)
	cons.print(string: "Done (0)\n")

	cons.print(string: "* TEST1\n")
	let groups1 = allocateOperations(sleepTime: 0.0, console: cons)
	queues.execute(operationGroups: groups1, timeLimit: 0.1)
	printOperations(operationGroups: groups1)
	cons.print(string: "Done (1)\n")

	cons.print(string: "* TEST2\n")
	let groups2 = allocateOperations(sleepTime: 1.0, console: cons)
	queues.execute(operationGroups: groups2, timeLimit: 0.1)
	printOperations(operationGroups: groups2)
	cons.print(string: "Done (2)\n")

	return true
}

private func allocateOperations(sleepTime stime: TimeInterval, console cons: CNConsole) -> Array<Array<UTOperation>>
{
	var groups: Array<Array<UTOperation>> = []
	for i in 0..<2 {
		var group: Array<UTOperation> = []
		for j in 0..<2 {
			group.append(UTOperation(identifier: i * 10 + j, sleepTime: stime, console: cons))
		}
		groups.append(group)
	}
	return groups
}

private func printOperations(operationGroups groups: Array<Array<UTOperation>>)
{
	for group in groups {
		for op in group {
			op.printState()
		}
	}
}

