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
	public enum State {
		case initial
		case done
		case cancelled
	}

	public  var state:			State
	private var mName:			String
	private var mDoWaitCancel:		Bool

	public required init(name nm: String, doWaitCancel dowait: Bool, input ifile: CNFile, output ofile: CNFile, error efile: CNFile) {
		state		= .initial
		mName		= nm
		mDoWaitCancel	= dowait
		super.init(input: ifile, output: ofile, error: efile)
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
			state = .cancelled
		} else {
			state = .done
		}
	}

	public func checkExectime(requiredCount count: Int) -> Bool {
		//outputFileHandle.write(string: "\(mName) : Check Exec Time \(self.executionCount) \(count)\n")
		if self.executionCount == count {
			return true
		}
		return false
	}
}

public func testOperation(console cons: CNFileConsole) -> Bool
{
	let ifile = cons.inputFile
	let ofile = cons.outputFile
	let efile = cons.errorFile

	let ctxt0 = UTOperationContext(name: "op0", doWaitCancel: false, input: ifile, output: ofile, error: efile)
	let ctxt1 = UTOperationContext(name: "op1", doWaitCancel: false, input: ifile, output: ofile, error: efile)
	let ctxt2 = UTOperationContext(name: "op2", doWaitCancel: true,  input: ifile, output: ofile, error: efile)

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
		cons.print(string: "testOperation ... OK\n")
	} else {
		cons.print(string: "testOperation ... NG\n")
		result = false
	}

	return result
}

