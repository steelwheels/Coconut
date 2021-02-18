/**
 * @file	UTToken.swift
 * @brief	Test function for CNToken class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testToken(console cons: CNConsole) -> Bool
{
	let teststrs: Array<String> = [
		"hello, world !!",
		"hello//comment\nworld!!",
		"a // comment\n",
		"b // comment"
	]
	var result = true
	for teststr in teststrs {
		if !testTokenToString(source: teststr, console: cons) {
			result = false
		}
	}
	return result
}

private func testTokenToString(source src: String, console cons: CNConsole) -> Bool
{
	var result = true

	cons.print(string: "Source: \"\(src)\"\n")
	let conf = CNParserConfig(allowIdentiferHasPeriod: true)
	switch CNStringToToken(string: src, config: conf) {
	case .ok(let tokens):
		cons.print(string: "Result:\n")
		for token in tokens {
			cons.print(string: " \(token.description)\n")
		}
	case .error(let err):
		cons.print(string: "Error: \(err.description())\n")
		result = false
	}
	return result
}

