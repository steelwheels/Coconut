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

	public override func main() {
		//NSLog("*** Main ***")
		super.main()
	}
}

public func testShell(console cons: CNConsole) -> Bool
{
	let env    = CNShellEnvironment()
	let config = CNConfig(doVerbose: true)
	let shell  = UTShellThread(input:  FileHandle.standardInput,
				   output: FileHandle.standardOutput,
				   error:  FileHandle.standardError,
				   environment: env,
				   config: config,
				   terminationHander: nil)
	FileHandle.standardOutput.writeabilityHandler = {
		(_ hdl: FileHandle) -> Void in
		let data = hdl.availableData
		if let str = String(data: data, encoding: .utf8) {
			cons.print(string: "testShell/Out: \"\(str)\"\n")
			shell.printed = true
		}
	}
	FileHandle.standardError.writeabilityHandler = {
		(_ hdl: FileHandle) -> Void in
		let data = hdl.availableData
		if let str = String(data: data, encoding: .utf8) {
			cons.print(string: "testShell/Err: \"\(str)\"\n")
			shell.printed = true
		}
	}
	let instr = "input-command"
	if let data = instr.data(using: .utf8) {
		FileHandle.standardInput.write(data)
	}

	shell.start()
	while !shell.printed {
	}
	shell.cancel()
	while !shell.isFinished {
	}

	return true
}

