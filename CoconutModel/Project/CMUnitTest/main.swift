/**
 * @file	main.swift
 * @brief	Define main function for unit test of CoconutModel framework
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import CoconutData
import CoconutModel
import Foundation

private struct Result {
	var name:	String
	var result:	Bool

	public init(name nm: String, result res: Bool){
		name   = nm
		result = res
	}
}

public func TestMain()
{
	var results: Array<Result> = []

	let cons = CNFileConsole()
	cons.print(string: "* Unit test for CoconutModel framework\n")

	results.append(execTest(name: "Earth", result: testEarth(console: cons), console: cons))

	/* Check results */
	cons.print(string: "* Results\n")
	var summary = true
	for res in results {
		if res.result {
			cons.print(string: "\(res.name) ... OK\n")
		} else {
			cons.print(string: "\(res.name) ... Error\n")
			summary = false
		}
	}
	if summary {
		cons.print(string: "SUMMARY ... OK\n")
	} else {
		cons.print(string: "SUMMARY ... Error\n")
	}
}

private func execTest(name nm: String, result res: Bool, console cons: CNConsole) -> Result {
	let result = Result(name: nm, result: res)
	if res {
		cons.print(string: "\(nm) ... OK\n")
	} else {
		cons.print(string: "\(nm) ... Error\n")
	}
	return result
}

TestMain()





