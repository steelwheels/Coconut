/**
 * @file	UTProcess.swift
 * @brief	Test function for CNProcess class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testProcess(console cons: CNFileConsole) -> Bool
{
	let env     = CNEnvironment()
	let process = CNProcess(input:  .fileHandle(cons.inputHandle),
				output: .fileHandle(cons.outputHandle),
				error:  .fileHandle(cons.errorHandle),
				environment: env,
				terminationHander: {
		(_ proc: Process) -> Void in
		cons.print(string: "END of process\n")
	})

	//let input = process.inputFileHandle
	process.execute(command: "echo \"Hello, World !!\"")
	//input.write(string: "Hello, World !!")
	//input.closeFile()

	let ecode = process.waitUntilExit()
	cons.print(string: "Process is finished with exit code: \(ecode)\n")
	return true
}

