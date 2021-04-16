/**
 * @file	UTCommandTavle.swift
 * @brief	Test function for CNCommandTable
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testCommandTable(console cons: CNFileConsole) -> Bool
{
	let env	     = CNEnvironment()
	let cmdtable = CNCommandTable()
	cmdtable.read(from: env)

	let names = cmdtable.names
	for name in names {
		cons.print(string: name + " ")
	}
	cons.print(string: "\n")

	let cmds = cmdtable.matchPrefix(string: "ls")
	cons.print(string: "match-prefix: ")
	for cmd in cmds {
		cons.print(string: "\(cmd) ")
	}
	cons.print(string: "\n")

	return true
}

