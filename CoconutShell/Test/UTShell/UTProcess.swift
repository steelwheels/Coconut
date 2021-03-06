/**
 * @file	UTProcess.swift
 * @brief	Test function for CNPipeProcess class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import CoconutShell
import Foundation

public func testProcess(console cons: CNConsole) -> Bool
{
	let procmgr = CNProcessManager()
	let instrm  = CNFileStream.fileHandle(FileHandle.standardInput)
	let outstrm = CNFileStream.fileHandle(FileHandle.standardOutput)
	let errstrm = CNFileStream.fileHandle(FileHandle.standardError)
	let env     = CNEnvironment()

	let process = CNProcess(processManager: procmgr, input: instrm, output: outstrm, error: errstrm, environment: env, terminationHander: {
		(_ process: Process) -> Void in
		cons.print(string: "[UTShell] Process finished\n")
	})

	cons.print(string: "[UTShell] Execute process: ls\n")
	process.execute(command: "/bin/ls")
	cons.print(string: "[UTShell] Execute process: wait until exit\n")
	let ecode = process.waitUntilExit()
	cons.print(string: "[UTShell] Execute process: done with exit code\(ecode)\n")

	return true
}

