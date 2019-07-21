/**
 * @file		UTOperation.swift
 * @brief	Test function for CNOperation class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

private class UTOperationContext: CNOperationContext
{
	private var mName:			String
	private var mDoWaitCancel:		Bool

	public required init(name nm: String, doWaitCancel dowait: Bool, console cons: CNConsole) {
		mName			= nm
		mDoWaitCancel		= dowait
		super.init(console: cons)
	}

	open override func main() {
		if self.mDoWaitCancel {
			var docont = true
			while docont {
				if self.isCancelled {
					//mConsole.print(string: "Canceled ... \(mName)\n")
					docont = false
				}
			}
		}
	}

	public func checkExectime(requiredCount count: Int) -> Bool {
		if self.executionCount == count {
			return true
		}
		return false
	}
}

public func testOperation(console cons: CNConsole) -> Bool
{
	let ctxt0 = UTOperationContext(name: "op0", doWaitCancel: false, console: cons)
	let ctxt1 = UTOperationContext(name: "op1", doWaitCancel: false, console: cons)
	let ctxt2 = UTOperationContext(name: "op2", doWaitCancel: true,  console: cons)

	let queue   = CNOperationQueue()
	let noexecs = queue.execute(operations: [ctxt0, ctxt1, ctxt2], timeLimit: nil)

	/* Wait op2 is started */
	while !ctxt2.isExecuting {
	}

	//cons.print(string: "Cancel OP2\n")
	ctxt2.cancel()

	cons.print(string: "Wait for finish operations\n")
	queue.waitOperations()

	/* Check exec count */
	var result = true
	if !ctxt0.checkExectime(requiredCount: 1) {
		cons.print(string: "[Error] Context0 exec check failed\n")
		result = false
	}
	if !ctxt1.checkExectime(requiredCount: 1) {
		cons.print(string: "[Error] Context1 exec check failed\n")
		result = false
	}
	if !ctxt2.checkExectime(requiredCount: 1) {
		cons.print(string: "[Error] Context2 exec check failed\n")
		result = false
	}

	if noexecs.count == 0 {
		cons.print(string: "testOperation ... Done\n")
	} else {
		cons.print(string: "testOperation ... Fail\n")
		result = false
	}
	return result
}

