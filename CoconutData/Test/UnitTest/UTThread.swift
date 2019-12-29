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
		self.console.print(string: "UTThread: mainOperation\n")
		return 0
	}
}

public class UTNestedThread: CNThread {
	private var mCount:	Int

	public init(queue disque: DispatchQueue, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, config conf: CNConfig, count cnt: Int) {
		mCount = cnt
		super.init(queue: disque, input: instrm, output: outstrm, error: errstrm, config: conf)
	}

	open override func main(arguments args: Array<CNNativeValue>) -> Int32 {
		self.console.print(string: "UTNestedThread\(mCount): mainOperation/start\n")
		if mCount < 3 {
			let newthread = UTNestedThread(queue: self.queue, input: self.inputStream, output: self.outputStream, error: self.errorStream, config: config, count: mCount + 1)
			self.console.print(string: "UTNestedThread\(mCount): mainOperation/main/start\n")
			newthread.start(arguments: [])
			self.console.print(string: "UTNestedThread\(mCount): mainOperation/main/waitUntilExit\n")
			let ecode = newthread.waitUntilExit()
			self.console.print(string: "UTNestedThread\(mCount): mainOperation/main/echode=\(ecode)\n")
		}
		self.console.print(string: "UTNestedThread\(mCount): mainOperation/done\n")
		return 0
	}
}

public func testThread(console cons: CNFileConsole) -> Bool
{
	let queue  = DispatchQueue(label: "UTThread", attributes: .concurrent)
	let config  = CNConfig(logLevel: .detail)
	let result0 = testSimpleThread(queue: queue, console: cons, config: config)
	let result1 = testNestedThread(queue: queue, console: cons, config: config)
	return result0 && result1
}

private func testSimpleThread(queue disque: DispatchQueue, console cons: CNFileConsole, config conf: CNConfig) -> Bool
{
	cons.print(string: "----- testSimpleThread\n")
	let thread = UTSimpleThread(queue:	disque,
			      input:  		.fileHandle(cons.inputHandle),
			      output: 		.fileHandle(cons.outputHandle),
			      error:  		.fileHandle(cons.errorHandle),
			      config: 		conf)
	thread.start(arguments: [])
	let ecode = thread.waitUntilExit()
	cons.print(string: "Wait done with exit code: \(ecode)\n")
	return true
}

private func testNestedThread(queue disque: DispatchQueue, console cons: CNFileConsole, config conf: CNConfig) -> Bool
{
	cons.print(string: "----- testNestedThread\n")
	let thread = UTNestedThread(queue:	disque,
			      input:  		.fileHandle(cons.inputHandle),
			      output: 		.fileHandle(cons.outputHandle),
			      error:  		.fileHandle(cons.errorHandle),
			      config: 		conf,
			      count: 		0)
	thread.start(arguments: [])
	let ecode = thread.waitUntilExit()
	cons.print(string: "Wait done with exit code: \(ecode)\n")
	return true
}

