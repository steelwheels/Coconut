/**
 * @file	UTOperationQueue.swift
 * @brief	Test function for CNOperationQueueclass
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

private class UTOperationContext: CNOperationContext
{
	private var mIdentifier:	Int
	private var mSleepTime:		TimeInterval

	public required init(identifier ident: Int, sleepTime stime: TimeInterval, console cons: CNConsole) {
		mIdentifier	= ident
		mSleepTime 	= stime
		super.init(console: cons)
	}

	open override func main() {
		Thread.sleep(forTimeInterval: self.mSleepTime)
	}

	public func printState(){
		//mConsole.print(string: "op[\(mIdentifier)] ... ")
		if self.isCancelled {
			console?.print(string: "Canceled\(mIdentifier)\n")
		} else if self.isFinished {
			console?.print(string: "Finished\(mIdentifier)\n")
		} else {
			console?.print(string: "??\(mIdentifier)\n")
		}
	}
}

public func testOperationQueue(console cons: CNConsole) -> Bool
{
	let queue = CNOperationQueue()

	cons.print(string: "* TEST0\n")
	let ctxts0 = allocateOperations(sleepTime: 0.0, console: cons)
	let res0   = checkQueue(results: queue.execute(operations: ctxts0, timeLimit: nil), console: cons)
	queue.waitOperations()
	printContexts(contexts: ctxts0)
	cons.print(string: "Done (0)\n")

	cons.print(string: "* TEST1\n")
	let ctxt1 = allocateOperations(sleepTime: 0.0, console: cons)
	let res1  = checkQueue(results: queue.execute(operations: ctxt1, timeLimit: 0.1), console: cons)
	queue.waitOperations()
	printContexts(contexts: ctxt1)
	cons.print(string: "Done (1)\n")

	cons.print(string: "* TEST2\n")
	let ctxts2 = allocateOperations(sleepTime: 1.0, console: cons)
	let res2   = checkQueue(results: queue.execute(operations: ctxts2, timeLimit: 0.1), console: cons)
	queue.waitOperations()
	printContexts(contexts: ctxts2)
	cons.print(string: "Done (2)\n")

	return res0 && res1 && res2
}

private func allocateOperations(sleepTime stime: TimeInterval, console cons: CNConsole) -> Array<UTOperationContext>
{
	var ctxts: Array<UTOperationContext> = []
	for i in 0..<2 {
		let ctxt = UTOperationContext(identifier: i, sleepTime: stime, console: cons)
		ctxts.append(ctxt)
	}
	return ctxts
}

private func printContexts(contexts ctxts: Array<UTOperationContext>)
{
	for ctxt in ctxts {
		ctxt.printState()
	}
}

private func checkQueue(results res: Array<CNOperationContext>, console cons: CNConsole) -> Bool {
	let result: Bool
	if res.count == 0 {
		result = true
	} else {
		cons.error(string: "[Error] Failed to enqueue operation\n")
		result = false
	}
	return result
}


