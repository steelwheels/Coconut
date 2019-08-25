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
	intf.connectWithStandardOutput()

	let env     = CNShellEnvironment()
	let conf    = CNConfig(doVerbose: true)
	let process = CNPipeProcess(interface: intf, environment: env, console: cons, config: conf)

	cons.print(string: "Execute process: ls\n")
	process.execute(command: "ls")
	process.waitUntilExit()

	return true
}

