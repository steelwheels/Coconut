/**
 * @file	UTUnixCommand.swift
 * @brief	Test function for CNUnixCommand class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutShell
import CoconutData
import Foundation

public func testUnixCommand(console cons: CNConsole) -> Bool
{
	let cmdtable = CNUnixCommandTable.shared
	let cmdnames = cmdtable.commandNames.sorted()

	cons.print(string: "Commands: ")
	for cmdname in cmdnames {
		cons.print(string: cmdname + " ")
	}
	cons.print(string: "\n")

	return true
}

