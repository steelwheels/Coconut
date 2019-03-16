/**
 * @file		UTOperation.swift
 * @brief	Test function for CNOperation class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

private class UTOperation: CNOperation
{
	private var mName:		String
	private var mDoWaitCancel:	Bool
	private var mConsole:		CNConsole

	public required init(name nm: String, doWaitCancel dowait: Bool, console cons: CNConsole) {
		mName		= nm
		mDoWaitCancel	= dowait
		mConsole	= cons
		super.init()

		self.mainFunction = {
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
}

public func testOperation(console cons: CNConsole) -> Bool
{
	let op0 = UTOperation(name: "op0", doWaitCancel: false, console: cons)
	let op1 = UTOperation(name: "op1", doWaitCancel: false, console: cons)
	let op2 = UTOperation(name: "op2", doWaitCancel: true,  console: cons)

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

