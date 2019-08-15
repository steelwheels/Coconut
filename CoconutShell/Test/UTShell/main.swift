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
	let console = CNFileConsole()

	let res0 = testShellUtil(console: console)
	let res1 = testShell(console: console)

	let result = res0 && res1
	if result {
		console.print(string: "Result: OK\n")
		Darwin.exit(0)
	} else {
		console.print(string: "Result: NG\n")
		Darwin.exit(1)
	}
}

main()


