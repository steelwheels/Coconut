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
	let res0 = testNormalProcess(command: "echo \"Hello, World !!\"", console: cons)
	//let res2 = testNormalProcess(command: "open -a /Applications/JSTerminal.app", console: cons)
	let res1 = testProcessTermination(console: cons)

	let result = res0 && res1 //&& res2
	if result {
		cons.print(string: "testProcess .. OK\n")
	} else {
		cons.print(string: "testProcess .. NG\n")
	}
	return result
}

private func testNormalProcess(command cmd: String, console cons: CNFileConsole) -> Bool
{
	let manager = CNProcessManager()
	let env     = CNEnvironment()
	let process = CNProcess(processManager: manager,
				input:  .fileHandle(cons.inputHandle),
				output: .fileHandle(cons.outputHandle),
				error:  .fileHandle(cons.errorHandle),
				environment: env,
				terminationHander: {
		(_ proc: Process) -> Void in
		cons.print(string: "END of process\n")
	})

	//let pid = manager.add(groupId: 0, process: process)
	//cons.print(string: "pid = \(pid)\n")

	//let input = process.inputFileHandle
	process.execute(command: cmd)
	//input.write(string: "Hello, World !!")
	//input.closeFile()

	while process.status == .Running {
		/* Wait until exit */
	}

	cons.print(string: "Process is finished with exit code: \(process.terminationStatus)\n")
	return true
}

private func testProcessTermination(console cons: CNFileConsole) -> Bool
{
	var result = true

	let manager = CNProcessManager()
	let env     = CNEnvironment()
	let process = CNProcess(processManager: manager,
				input:  .fileHandle(cons.inputHandle),
				output: .fileHandle(cons.outputHandle),
				error:  .fileHandle(cons.errorHandle),
				environment: env,
				terminationHander: {
		(_ proc: Process) -> Void in
		cons.print(string: "END of process\n")
	})

	cons.print(string: "Execute process which can not be finished\n")
	process.execute(command: "/bin/sleep 100") // Stop because no input

	Thread.sleep(forTimeInterval: 0.5)	// async wait
	if process.status != .Running {
		cons.print(string: "Process is already NOT running\n")
		result = false
	}

	cons.print(string: "Terminate the process\n")
	process.terminate()

	Thread.sleep(forTimeInterval: 0.5)	// async wait
	if process.status == .Running {
		cons.print(string: "Process must be stopped\n")
		result = false
	}

	while process.status == .Running {
		/* Wait until finish */
	}

	let ecode = process.terminationStatus
	cons.print(string: "Process is terminated with exit code: \(ecode)\n")

	return result
}

