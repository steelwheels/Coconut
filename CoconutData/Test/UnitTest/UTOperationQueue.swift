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

	public required init(identifier ident: Int, sleepTime stime: TimeInterval, input inhdl: FileHandle, output outhdl: FileHandle, error errhdl: FileHandle) {
		mIdentifier		= ident
		mSleepTime 		= stime
		super.init(input: inhdl, output: outhdl, error: errhdl)
	}

	open override func main() {
		//console?.print(string: "UTOperationContext.main: \(mIdentifier) ... sleep \(mSleepTime)\n")
		let looptime = self.mSleepTime / 10.0
		for _ in 0..<10 {
			if isCancelled {
				break
			} else {
				Thread.sleep(forTimeInterval: looptime)
			}
		}
	}

	public func printState(){
		//mConsole.print(string: "op[\(mIdentifier)] ... ")
		if self.isCancelled {
			self.outputFileHandle.write(string: "Canceled\(mIdentifier)\n")
		//} else if self.isFinished {
		//	self.outputFileHandle.write(string: "Finished\(mIdentifier)\n")
		} else {
			self.outputFileHandle.write(string: "Unknown\(mIdentifier)\n")
		}
	}
}

public func testOperationQueue(console cons: CNFileConsole) -> Bool
{
	let queue = CNOperationQueue()

	let inhdl  = cons.inputHandle
	let outhdl = cons.outputHandle
	let errhdl = cons.errorHandle

	cons.print(string: "* TEST0\n")
	let ctxts0 = allocateOperations(sleepTime: 0.0, input: inhdl, output: outhdl, error: errhdl)
	let res0   = checkQueue(results: queue.execute(operations: ctxts0, timeLimit: nil), console: cons)
	queue.waitOperations()
	printContexts(contexts: ctxts0, console: cons)
	cons.print(string: "Done (0)\n")

	cons.print(string: "* TEST1\n")
	let ctxt1 = allocateOperations(sleepTime: 0.0, input: inhdl, output: outhdl, error: errhdl)
	let res1  = checkQueue(results: queue.execute(operations: ctxt1, timeLimit: 0.1), console: cons)
	queue.waitOperations()
	printContexts(contexts: ctxt1, console: cons)
	cons.print(string: "Done (1)\n")

	cons.print(string: "* TEST2\n")
	let ctxts2 = allocateOperations(sleepTime: 1.0, input: inhdl, output: outhdl, error: errhdl)
	let res2   = checkQueue(results: queue.execute(operations: ctxts2, timeLimit: 0.1), console: cons)
	queue.waitOperations()
	printContexts(contexts: ctxts2, console: cons)
	cons.print(string: "Done (2)\n")

	var result = false
	if res0 && res1 && res2 {
		cons.print(string: "testOperationQueue: OK\n")
		result = true
	} else {
		cons.print(string: "testOperationQueue: NG\n")
	}
	return result
}

private func allocateOperations(sleepTime stime: TimeInterval, input inhdl: FileHandle, output outhdl: FileHandle, error errhdl: FileHandle) -> Array<UTOperationContext>
{
	var ctxts: Array<UTOperationContext> = []
	for i in 0..<2 {
		let ctxt = UTOperationContext(identifier: i, sleepTime: stime, input: inhdl, output: outhdl, error: errhdl)
		ctxts.append(ctxt)
	}
	return ctxts
}

private func printContexts(contexts ctxts: Array<UTOperationContext>, console cons: CNConsole)
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


