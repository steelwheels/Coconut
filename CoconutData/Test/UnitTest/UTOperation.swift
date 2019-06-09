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
	private var mName:		String
	private var mDoWaitCancel:	Bool

	public required init(name nm: String, doWaitCancel dowait: Bool, console cons: CNConsole) {
		mName		= nm
		mDoWaitCancel	= dowait
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
}

public func testOperation(console cons: CNConsole) -> Bool
{
	let ctxt0 = UTOperationContext(name: "op0", doWaitCancel: false, console: cons)
	let ctxt1 = UTOperationContext(name: "op1", doWaitCancel: false, console: cons)
	let ctxt2 = UTOperationContext(name: "op2", doWaitCancel: true,  console: cons)

	let op0   = CNOperationExecutor(context: ctxt0)
	let op1   = CNOperationExecutor(context: ctxt1)
	let op2   = CNOperationExecutor(context: ctxt2)

	let queue = OperationQueue()
	queue.addOperation(op0)
	queue.addOperation(op1)
	queue.addOperation(op2)

	/* Wait op2 is started */
	while !op2.isExecuting {
	}

	//cons.print(string: "Cancel OP2\n")
	op2.cancel()

	cons.print(string: "Wait for finish operations\n")
	queue.waitUntilAllOperationsAreFinished()
	
	return true
}

