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
		self.console.print(string: "testSimpleThread: 2. MainOperation\n")
		return 0
	}
}

public class UTNestedThread: CNThread {
	private var mCount:	Int

	public init(queue disque: DispatchQueue, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, count cnt: Int) {
		mCount = cnt
		super.init(queue: disque, input: instrm, output: outstrm, error: errstrm)
	}

	open override func main(arguments args: Array<CNNativeValue>) -> Int32 {
		self.console.print(string: "testNestedThread\(mCount): 1.mainOperation/start\n")
		if mCount < 3 {
			let newthread = UTNestedThread(queue: self.queue, input: self.inputStream, output: self.outputStream, error: self.errorStream, count: mCount + 1)
			self.console.print(string: "testNestedThread\(mCount): 2.1 mainOperation/main/start\n")
			newthread.start(arguments: [])
			self.console.print(string: "testNestedThread\(mCount): 2.2 mainOperation/main/waitUntilExit\n")
			let ecode = newthread.waitUntilExit()
			self.console.print(string: "testNestedThread\(mCount): 2.3 mainOperation/main/echode=\(ecode)\n")
		}
		self.console.print(string: "testNestedThread\(mCount): 3.mainOperation/done\n")
		return 0
	}
}

public func testThread(console cons: CNFileConsole) -> Bool
{
	let queue  = DispatchQueue(label: "UTThread", attributes: .concurrent)
	let result0 = testSimpleThread(queue: queue, console: cons)
	let result1 = testNestedThread(queue: queue, console: cons)
	return result0 && result1
}

private func testSimpleThread(queue disque: DispatchQueue, console cons: CNFileConsole) -> Bool
{
	cons.print(string: "testSimpleThread: 1. Begin\n")
	let thread = UTSimpleThread(queue:	disque,
			      input:  		.fileHandle(cons.inputHandle),
			      output: 		.fileHandle(cons.outputHandle),
			      error:  		.fileHandle(cons.errorHandle))
	thread.start(arguments: [])
	let ecode = thread.waitUntilExit()
	cons.print(string: "testSimpleThread: 3: ecode = \(ecode)\n")
	return true
}

private func testNestedThread(queue disque: DispatchQueue, console cons: CNFileConsole) -> Bool
{
	cons.print(string: "testNestedThread: 1. Begin\n")
	let thread = UTNestedThread(queue:	disque,
			      input:  		.fileHandle(cons.inputHandle),
			      output: 		.fileHandle(cons.outputHandle),
			      error:  		.fileHandle(cons.errorHandle),
			      count: 		0)
	thread.start(arguments: [])
	let ecode = thread.waitUntilExit()
	cons.print(string: "testNestedThread: 2. End code: \(ecode)\n")
	return true
}

