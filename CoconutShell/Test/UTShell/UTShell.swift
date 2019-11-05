/**
 * @file	UTShell.swift
 * @brief	Test function for CNShell class
 * @par Copyright
 *   Copyright (C) 2015-2019 Steel Wheels Project
 */

import CoconutShell
import CoconutData
import Foundation

public class UTShellThread: CNShellThread {
	public var printed = false

	public override func promptString() -> String {
		return "UTShell$ "
	}

	open override func execute(command cmd: String) {
		console.print(string: "UTShell/In \"\(cmd)\"\n")
		printed = true
	}
}

public func testShell(console cons: CNFileConsole) -> Bool
{
	let inpipe  = Pipe()
	let outpipe = Pipe()
	let errpipe = Pipe()


	let instrm  = CNFileStream.pipe(inpipe)
	let outstrm = CNFileStream.pipe(outpipe)
	let errstrm = CNFileStream.pipe(errpipe)
	let env     = CNShellEnvironment()
	let config  = CNConfig(logLevel: .detail)
	let shell   = UTShellThread(input: instrm, output: outstrm, error: errstrm,
				   environment: env,
				   config: config,
				   terminationHander: nil)

	outpipe.fileHandleForReading.readabilityHandler = {
		(_ hdl: FileHandle) -> Void in
		let data = hdl.availableData
		if let str = String(data: data, encoding: .utf8) {
			cons.print(string: "UTShell/Out: \"\(str)\"\n")
		}
	}

	errpipe.fileHandleForReading.readabilityHandler = {
		(_ hdl: FileHandle) -> Void in
		let data = hdl.availableData
		if let str = String(data: data, encoding: .utf8) {
			cons.print(string: "UTShell/Err: \"\(str)\"\n")
		}
	}

	cons.print(string: "testShell: Start\n")
	shell.start()

	/* input command */
	shell.inputFileHandle.write(string: "shell-command\n")
	shell.inputFileHandle.closeFile()

	/* Wait some prited */
	while !shell.printed {
	}

	shell.cancel()
	while !shell.isFinished {
	}
	cons.print(string: "testShell: Cancelled\n")

	return true
}

