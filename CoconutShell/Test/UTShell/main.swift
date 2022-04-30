/**
 * @file	main.swift
 * @brief	Main function for unit test
 * @par Copyright
 *   Copyright (C) 2015-2019 Steel Wheels Project
 */

import CoconutData
import CoconutShell
import Foundation
import Darwin

print("Hello, World!")

public func main() {
	let environment = CNEnvironment()
	let console     = CNFileConsole()
	let terminfo    = CNTerminalInfo(width: 80, height: 25)

	console.print(string: "** testShellUtil\n")
	let res0 = testShellUtil(console: console)

	console.print(string: "** testProcess\n")
	let res1 = testProcess(console: console)

	console.print(string: "** unixCommands\n")
	let res2 = testUnixCommand(console: console)

	console.print(string: "** testShell\n")
	let res3 = testShell(console: console)

	console.print(string: "** testReadline\n")
	let res4 = testReadline(environment: environment, console: console, terminalInfo: terminfo)

	console.print(string: "** testComplementor\n")
	let res5 = testComplementor(console: console, environment: environment, terminalInfo: terminfo)

	let result = res0 && res1 && res2 && res3 && res4 && res5
	if result {
		console.print(string: "Result: OK\n")
		Darwin.exit(0)
	} else {
		console.print(string: "Result: NG \(res0) \(res1) \(res2) \(res3) \(res4)\n")
		Darwin.exit(1)
	}
}

main()


