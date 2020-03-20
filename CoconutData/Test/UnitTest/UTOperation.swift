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

	public required init(name nm: String, doWaitCancel dowait: Bool, input inhdl: FileHandle, output outhdl: FileHandle, error errhdl: FileHandle) {
		mName			= nm
		mDoWaitCancel		= dowait
		super.init(input: inhdl, output: outhdl, error: errhdl)
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
			outputFileHandle.write(string: "\(mName) : Canceled\n")
		} else {
			outputFileHandle.write(string: "\(mName) : Done\n")
		}
	}

	public func checkExectime(requiredCount count: Int) -> Bool {
		outputFileHandle.write(string: "\(mName) : Check Exec Time \(self.executionCount) \(count)\n")
		if self.executionCount == count {
			return true
		}
		return false
	}
}

public func testOperation(console cons: CNFileConsole) -> Bool
{
	let inhdl  = cons.inputHandle
	let outhdl = cons.outputHandle
	let errhdl = cons.errorHandle

	let ctxt0 = UTOperationContext(name: "op0", doWaitCancel: false, input: inhdl, output: outhdl, error: errhdl)
	let ctxt1 = UTOperationContext(name: "op1", doWaitCancel: false, input: inhdl, output: outhdl, error: errhdl)
	let ctxt2 = UTOperationContext(name: "op2", doWaitCancel: true,  input: inhdl, output: outhdl, error: errhdl)

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

