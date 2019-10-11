/**
 * @file	UTFilePath.swift
 * @brief	Test function for CNFilePass class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testFilePath(console cons: CNConsole) -> Bool
{
	var result0: Bool

	/* URI */
	let url = URL(fileURLWithPath: "Info.plist")
	if let uti = CNFilePath.UTIForFile(URL: url) {
		cons.print(string: "UTI: \(uti) \n")
		result0 = true
	} else {
		cons.print(string: "Error: No UTI\n")
		result0 = false
	}

	/* Scheme */
	let result10 = testScemeInString(string: "/usr/local/bin", expectedResult: false, console: cons)
	let result11 = testScemeInString(string: "https://yahoo.com", expectedResult: true, console: cons)
	let result12 = testScemeInString(string: "https//yahoo.com", expectedResult: false, console: cons)
	let result13 = testScemeInString(string: "ftp.c://yahoo.com", expectedResult: true, console: cons)

	return result0 && result10 && result11 && result12 && result13
}

private func testScemeInString(string str: String, expectedResult eval: Bool, console cons: CNConsole) -> Bool {
	var result: Bool
	cons.print(string: "Get sceme from \"\(str)\" -> ")
	if let resstr = CNFilePath.schemeInString(string: str) {
		cons.print(string: "Sceme:\"\(resstr)\" -> ")
		if eval {
			cons.print(string: "OK\n")
			result = true
		} else {
			cons.print(string: "NG\n")
			result = false
		}
	} else {
		cons.print(string: "<none> -> ")
		if eval {
			cons.print(string: "NG\n")
			result = false
		} else {
			cons.print(string: "OK\n")
			result = true
		}
	}
	return result
}
