/**
 * @file	UTCompiementor.swift
 * @brief	Test function for CNComplementor class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutShell
import CoconutData
import Foundation

public func testComplementor(console cons: CNFileConsole, environment env: CNEnvironment, terminalInfo terminfo: CNTerminalInfo) -> Bool
{
	let compl = CNComplementor()
	let teststrs = [
		"non-exist",
		"  a ",
		"",
		"ls",
		"test",
		"lsof",
		"ls file",
		"ls file "
	]
	for teststr in teststrs {
		complement(string: teststr, console: cons, complementor: compl, environment: env, terminalInfo: terminfo)
	}
	return true
}

private func complement(string str: String, console cons: CNConsole, complementor compl: CNComplementor, environment env: CNEnvironment, terminalInfo terminfo: CNTerminalInfo)
{
	cons.print(string: "Test \"\(str)\" => ")
	compl.beginComplement(commandString: str, console: cons, environment: env, terminalInfo: terminfo)
	switch compl.complementState {
	case .none:
		cons.print(string: "<none>\n")
	case .matched(let str):
		cons.print(string: "Matched ... \(str)\n")
	case .popup(let num):
		cons.print(string: "Popup .... \(num)")
	}
}

