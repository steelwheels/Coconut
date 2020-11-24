/**
 * @file	main.swift
 * @brief	Define main function for unit test
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public func main()
{
	let console = CNFileConsole()
	console.print(string: "Unit test for CoconutDatabase framework\n")

	console.print(string: "*** UTAddressbook\n")
	let res0 = UTAddressbook(console: console)

	let result = res0
	if result {
		console.print(string: "SUMMARY: OK\n")
	} else {
		console.print(string: "SUMMARY: NG\n")
	}
}

main()


