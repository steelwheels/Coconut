/**
 * @file	UTShellUtil.swift
 * @brief	Test function for CNShellUtil class
 * @par Copyright
 *   Copyright (C) 2015-2019 Steel Wheels Project
 */

import CoconutShell
import CoconutData
import Foundation

public func testShellUtil(console cons: CNConsole) -> Bool
{
	let file = CNFileConsole()
	let process = CNShellUtil.execute(command: "ls", console: file, terminateHandler: {
		(_ exitcode: Int32) -> Void in
		file.print(string: "*** /bin/ls ... done\n")
	})
	process.waitUntilExit()
	return true
}

