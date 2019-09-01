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
	let intf    = CNShellInterface()
	intf.connectWithStandardInput()
	intf.connectWithStandardOutput()
	intf.connectWithStandardError()

	let env     = CNShellEnvironment()
	let conf    = CNConfig(doVerbose: true)
	let process = CNPipeProcess(interface: intf, environment: env, console: cons, config: conf){
		(_ process: Process) -> Void in
		cons.print(string: "[UTShell] Process finished\n")
	}

	cons.print(string: "[UTShell] Execute process: ls\n")
	process.execute(command: "/bin/ls")
	cons.print(string: "[UTShell] Execute process: wait until exit\n")
	process.waitUntilExit()
	cons.print(string: "[UTShell] Execute process: done\n")

	return true
}

