/**
 * @file	UTThread.swift
 * @brief	Test function for CNThread class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public class UTSimpleThread: CNThread {
	open override func main(argument arg: CNNativeValue) -> Int32 {
		//self.console.print(string: "testSimpleThread: 2. MainOperation\n")
		return 0
	}
}

public class UTNestedThread: CNThread {
	private var mCount:	Int

	public init(processManager procmgr: CNProcessManager, input ifile: CNFile, output ofile: CNFile, error efile: CNFile, environment env: CNEnvironment, count cnt: Int) {
		mCount = cnt
		super.init(processManager: procmgr, input: ifile, output: ofile, error: efile, environment: env)
	}

	open override func main(argument arg: CNNativeValue) -> Int32 {
		let procmgr = CNProcessManager()
		//self.console.print(string: "testNestedThread\(mCount): 1.mainOperation/start\n")
		if mCount < 3 {
			let newthread = UTNestedThread(processManager: procmgr, input: self.console.inputFile, output: self.console.outputFile, error: self.console.errorFile, environment: self.environment, count: mCount + 1)
			//self.console.print(string: "testNestedThread\(mCount): 2.1 mainOperation/main/start\n")
			newthread.start(argument: .nullValue)
			//self.console.print(string: "testNestedThread\(mCount): 2.2 mainOperation/main/waitUntilExit\n")
			while newthread.status == .Running {
				/* Wait until exit */
			}
			//self.console.print(string: "testNestedThread\(mCount): 2.3 mainOperation/main/echode=\(ecode)\n")
		}
		//self.console.print(string: "testNestedThread\(mCount): 3.mainOperation/done\n")
		return 0
	}
}

public func testThread(console cons: CNFileConsole) -> Bool
{
	let manager = CNProcessManager()
	let env     = CNEnvironment()
	let result0 = testSimpleThread(processManager: manager, environment: env, console: cons)
	let result1 = testNestedThread(processManager: manager, environment: env, console: cons)

	let result = result0 && result1
	if result {
		cons.print(string: "testThread .. OK\n")
	} else {
		cons.print(string: "testThread .. NG\n")
	}
	return result
}

private func testSimpleThread(processManager procmgr: CNProcessManager, environment env: CNEnvironment, console cons: CNFileConsole) -> Bool
{
	cons.print(string: "testSimpleThread: 1. Begin\n")
	let thread = UTSimpleThread(processManager:	procmgr,
				    input:  		cons.inputFile,
				    output: 		cons.outputFile,
				    error:  		cons.errorFile,
				    environment: 	env)
	thread.start(argument: .nullValue)
	while thread.status == .Running {
		/* wait until exit */
	}
	let ecode = thread.terminationStatus
	cons.print(string: "testSimpleThread: 3: ecode = \(ecode)\n")
	return true
}

private func testNestedThread(processManager procmgr: CNProcessManager, environment env: CNEnvironment, console cons: CNFileConsole) -> Bool
{
	cons.print(string: "testNestedThread: 1. Begin\n")
	let thread = UTNestedThread(processManager: procmgr,
				    input:  	cons.inputFile,
				    output: 	cons.outputFile,
				    error:  	cons.errorFile,
				    environment: env,
				    count: 	 0)
	thread.start(argument: .nullValue)
	while thread.status == .Running {
		/* wait until exit */
	}
	let ecode = thread.terminationStatus
	cons.print(string: "testNestedThread: 2. End code: \(ecode)\n")
	return true
}

