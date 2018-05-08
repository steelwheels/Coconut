/**
 * @file	main.swift
 * @brief	Main function for unit tests
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation
import Darwin

let console = CNFileConsole()
console.print(string: "Hello, World!\n")

console.print(string: "* testValue\n")
let result0 = testValue(console: console)

console.print(string: "* testConsole\n")
let result1 = testConsole(console: console)

let result = result0 && result1
if result {
	console.print(string: "[Result] OK\n")
	Darwin.exit(0)
} else {
	console.print(string: "[Result] NG\n")
	Darwin.exit(1)
}

