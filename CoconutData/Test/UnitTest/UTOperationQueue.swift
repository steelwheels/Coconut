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

	public var finalOperationDone:	Bool

	public required init(identifier ident: Int, sleepTime stime: TimeInterval, console cons: CNConsole) {
		mIdentifier		= ident
		mSleepTime 		= stime
		finalOperationDone 	= false
		super.init(console: cons)
	}

	open override func mainOperation() {
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

	var finalnum = 0
	let finalop = {
		(_ ctxt: CNOperationContext) -> Void in
		if let uctxt = ctxt as? UTOperationContext {
			uctxt.finalOperationDone = true
		}
		cons.print(string: "Finished\n")
		finalnum += 1
	}
	
	cons.print(string: "* TEST0\n")
	let ctxts0 = allocateOperations(sleepTime: 0.0, console: cons)
	let res0   = checkQueue(results: queue.execute(operations: ctxts0, timeLimit: nil, finalOperation: finalop), console: cons)
	queue.waitOperations()
	printContexts(contexts: ctxts0, console: cons)
	cons.print(string: "Done (0)\n")

	cons.print(string: "* TEST1\n")
	let ctxt1 = allocateOperations(sleepTime: 0.0, console: cons)
	let res1  = checkQueue(results: queue.execute(operations: ctxt1, timeLimit: 0.1, finalOperation: finalop), console: cons)
	queue.waitOperations()
	printContexts(contexts: ctxt1, console: cons)
	cons.print(string: "Done (1)\n")

	cons.print(string: "* TEST2\n")
	let ctxts2 = allocateOperations(sleepTime: 1.0, console: cons)
	let res2   = checkQueue(results: queue.execute(operations: ctxts2, timeLimit: 0.1, finalOperation: finalop), console: cons)
	queue.waitOperations()
	printContexts(contexts: ctxts2, console: cons)
	cons.print(string: "Done (2)\n")

	var result = false
	if res0 && res1 && res2 {
		if finalnum == 2 * 3 {
			cons.print(string: "testOperationQueue: OK\n")
			result = true
		} else {
			cons.print(string: "testOperationQueue: Some operation is NOT finished: \(finalnum)\n")
		}
	} else {
		cons.print(string: "testOperationQueue:Unexpected results\n")
	}
	return result
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

private func printContexts(contexts ctxts: Array<UTOperationContext>, console cons: CNConsole)
{
	for ctxt in ctxts {
		if ctxt.finalOperationDone {
			ctxt.printState()
		} else {
			cons.error(string: "Operation is NOT finished\n")
		}
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


