/**
 * @file	UTConsole.swift
 * @brief	Test function for CNConsole class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testConsole(console cons: CNConsole) -> Bool
{
	let res0 = testBufferConsole(console: cons)
	return res0
}

public func testBufferConsole(console cons: CNConsole) -> Bool
{
	let bufcons = CNBufferedConsole()
	cons.print(string: "- put string to buffer\n")
	bufcons.print(string: "buffer1\n")
	bufcons.print(string: "buffer2\n")

	cons.print(string: "- flush buffer\n")
	bufcons.outputConsole = cons

	cons.print(string: "- after buffered\n")
	bufcons.print(string: "after1\n")

	return true
}


