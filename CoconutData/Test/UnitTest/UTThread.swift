/**
 * @file	UTThread.swift
 * @brief	Test function for CNThread class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public class UTSimpleThread: CNThread {
	open override func main(arguments args: Array<CNNativeValue>) -> Int32 {
		//self.console.print(string: "testSimpleThread: 2. MainOperation\n")
		return 0
	}
}

public class UTNestedThread: CNThread {
	private var mCount:	Int

	public init(processManager procmgr: CNProcessManager, queue disque: DispatchQueue, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, environment env: CNEnvironment, count cnt: Int) {
		mCount = cnt
		super.init(processManager: procmgr, queue: disque, input: instrm, output: outstrm, error: errstrm, environment: env)
	}

	open override func main(arguments args: Array<CNNativeValue>) -> Int32 {
		let procmgr = CNProcessManager()
		let queue   = DispatchQueue(label: "UTNestedThread", qos: .default, attributes: .concurrent)
		//self.console.print(string: "testNestedThread\(mCount): 1.mainOperation/start\n")
		if mCount < 3 {
			let newthread = UTNestedThread(processManager: procmgr, queue: queue, input: self.inputStream, output: self.outputStream, error: self.errorStream, environment: self.environment, count: mCount + 1)
			//self.console.print(string: "testNestedThread\(mCount): 2.1 mainOperation/main/start\n")
			newthread.start(arguments: [])
			//self.console.print(string: "testNestedThread\(mCount): 2.2 mainOperation/main/waitUntilExit\n")
			let _ = newthread.waitUntilExit()
			//self.console.print(string: "testNestedThread\(mCount): 2.3 mainOperation/main/echode=\(ecode)\n")
		}
		//self.console.print(string: "testNestedThread\(mCount): 3.mainOperation/done\n")
		return 0
	}
}

public func testThread(console cons: CNFileConsole) -> Bool
{
	let manager = CNProcessManager()
	let queue   = DispatchQueue(label: "UTThread", attributes: .concurrent)
	let env     = CNEnvironment()
	let result0 = testSimpleThread(processManager: manager, queue: queue, environment: env, console: cons)
	let result1 = testNestedThread(processManager: manager, queue: queue, environment: env, console: cons)
	return result0 && result1
}

private func testSimpleThread(processManager procmgr: CNProcessManager, queue disque: DispatchQueue, environment env: CNEnvironment, console cons: CNFileConsole) -> Bool
{
	cons.print(string: "testSimpleThread: 1. Begin\n")
	let thread = UTSimpleThread(processManager:	procmgr,
				    queue:		disque,
				    input:  		.fileHandle(cons.inputHandle),
				    output: 		.fileHandle(cons.outputHandle),
				    error:  		.fileHandle(cons.errorHandle),
				    environment: 	env)
	thread.start(arguments: [])
	let ecode = thread.waitUntilExit()
	cons.print(string: "testSimpleThread: 3: ecode = \(ecode)\n")
	return true
}

private func testNestedThread(processManager procmgr: CNProcessManager, queue disque: DispatchQueue, environment env: CNEnvironment, console cons: CNFileConsole) -> Bool
{
	cons.print(string: "testNestedThread: 1. Begin\n")
	let thread = UTNestedThread(processManager: procmgr,
				    queue:	disque,
				    input:  	.fileHandle(cons.inputHandle),
				    output: 	.fileHandle(cons.outputHandle),
				    error:  	.fileHandle(cons.errorHandle),
				    environment: env,
				    count: 	 0)
	thread.start(arguments: [])
	let ecode = thread.waitUntilExit()
	cons.print(string: "testNestedThread: 2. End code: \(ecode)\n")
	return true
}

