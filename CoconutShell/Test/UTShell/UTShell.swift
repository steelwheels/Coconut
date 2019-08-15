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
	public override func main() {
		//NSLog("*** Main ***")
		super.main()
	}
}

public func testShell(console cons: CNConsole) -> Bool
{
	let intf  = CNShellInterface()
	let shell = UTShell(interface: intf)
	intf.stdout.receiverFunction = {
		(_ str: String) -> Void in
		cons.print(string: "testShell/Out: \"\(str)\"\n")
		shell.printed = true
	}
	intf.stderr.receiverFunction = {
		(_ str: String) -> Void in
		cons.print(string: "testShell/Err: \"\(str)\"\n")
		shell.printed = true
	}

	shell.prompt = "UTShell$ "
	intf.stdin.send(string: "input-command")

	shell.start()
	while !shell.printed {
	}
	shell.cancel()
	while !shell.isFinished {
	}

	return true
}

