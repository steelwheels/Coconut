/**
 * @file	UTThread.swift
 * @brief	Test function for CNThread class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

private class UTThread: CNThread {
	open override func mainOperation() -> Int32 {
		self.console.print(string: "UTThread: mainOperation\n")
		return 0
	}
}

public func testThread(console cons: CNFileConsole) -> Bool
{
	let thread = UTThread(input: .fileHandle(cons.inputHandle),
			      output: .fileHandle(cons.outputHandle),
			      error:  .fileHandle(cons.errorHandle),
			      terminationHander: {
				(_ thread: Thread) -> Int32 in
				cons.print(string: "UTThread: finished\n")
				return 0
		     })
	thread.start()
	let ecode = thread.waitUntilExit()
	cons.print(string: "Wait done with exit code: \(ecode)\n")
	return true
}

