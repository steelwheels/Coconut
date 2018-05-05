/**
 * @file	main.swift
 * @brief	Main function for unit tests
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation
import Darwin

let console = CNConsole()
console.print(string: "Hello, World!\n")

let result0 = testValue(console: console)

if result0 {
	console.print(string: "[Result] OK\n")
	Darwin.exit(0)
} else {
	console.print(string: "[Result] NG\n")
	Darwin.exit(1)
}

