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
	let process = CNProcess(terminationHander: {
		(_ proc: Process) -> Void in
		cons.print(string: "END of process\n")
	})

	process.set(outputWriterHandler: {
		(_ str: String) -> Void in
		cons.print(string: "OUTPUT: \(str)")
	})

	//let input = process.inputFileHandle
	process.execute(command: "echo \"Hello, World !!\"")
	//input.write(string: "Hello, World !!")
	//input.closeFile()

	let ecode = process.waitUntilExit()
	cons.print(string: "Process is finished with exit code: \(ecode)\n")
	return true
}

