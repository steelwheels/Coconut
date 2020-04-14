/**
 * @file	UTFileHandle.swift
 * @brief	Test function for FileHandle extension
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testFileHandle(console cons: CNConsole) -> Bool
{
	let hdl = FileHandle.standardInput
	cons.print(string: "FileDescriptor = \(hdl.fileDescriptor)\n")

	cons.print(string: "- Initial state -> ")
	printMode(fileHandle: hdl, console: cons)

	cons.print(string: "- Set raw mode -> ")
	if hdl.setRawMode(enable: true) == 0 {
		cons.print(string: "OK .. ")
		printMode(fileHandle: hdl, console: cons)
	} else {
		cons.print(string: "Failed\n")
	}

	cons.print(string: "- Reset raw mode -> ")
	if hdl.setRawMode(enable: false) == 0 {
		cons.print(string: "OK .. ")
		printMode(fileHandle: hdl, console: cons)
	} else {
		cons.print(string: "Failed\n")
	}

	return true
}

private func printMode(fileHandle hdl: FileHandle, console cons: CNConsole){
	if hdl.isAtty() {
		cons.print(string: "isatty: true,  ")
	} else {
		cons.print(string: "isatty: false, ")
	}

	if let mode = hdl.localMode {
		cons.print(string: "local mode: \(mode.description)\n")
	} else {
		cons.print(string: "local mode: <unknown>\n")
	}
}

