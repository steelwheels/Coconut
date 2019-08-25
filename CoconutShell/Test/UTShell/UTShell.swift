/**
 * @file	UTShell.swift
 * @brief	Test function for CNShell class
 * @par Copyright
 *   Copyright (C) 2015-2019 Steel Wheels Project
 */

import CoconutShell
import CoconutData
import Foundation

public class UTShellThread: CNShellThread {
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
	let env    = CNShellEnvironment()
	let config = CNConfig(doVerbose: true)
	let intf   = CNShellInterface()
	let shell  = UTShellThread(interface: intf, environment: env, console: cons, config: config)
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

