/**
 * @file	UTShell.swift
 * @brief	Test function for CNShell class
 * @par Copyright
 *   Copyright (C) 2015-2019 Steel Wheels Project
 */

import CoconutShell
import CoconutData
import Foundation

public class UTShell: CNShell {
	public var printed = false

	public override func promptString() -> String {
		return "UTShell$ "
	}

	public override func main() {
		//NSLog("*** Main ***")
		super.main()
	}
}

public func testShell(console cons: CNConsole) -> Bool
{
	let intf  = CNShellInterface()
	let shell = UTShell(interface: intf, console: cons)
	intf.output.setReader(handler: {
		(_ str: String) -> Void in
		cons.print(string: "testShell/Out: \"\(str)\"\n")
		shell.printed = true
	})
	intf.error.setReader(handler: {
		(_ str: String) -> Void in
		cons.print(string: "testShell/Err: \"\(str)\"\n")
		shell.printed = true
	})

	intf.input.write(string: "input-command")

	shell.start()
	while !shell.printed {
	}
	shell.cancel()
	while !shell.isFinished {
	}

	return true
}

